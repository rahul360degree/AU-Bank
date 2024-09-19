/**
* @author Subhadeep Sarkar
* @company Salesforce.com
* @description: This trigger framework bundles a single TriggerHandler base class that you can inherit from in all of your trigger handlers. 
The base class includes context-specific methods that are automatically called when a trigger is executed.
The base class also provides a secondary role as a supervisor for Trigger execution. 
It acts like a watchdog, monitoring trigger activity and providing an api for controlling certain aspects of execution and control flow.
* Test Class: TriggerHandler_Test
* History:
* <14 June 2024> <Subhadeep Sarkar> <Initial Trigger Framework>
*/


public virtual class AUSF_TriggerHandler {

    // Variable Declaration and Initialization
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    @TestVisible
    private static Map<String,List<Business_Unit_Data__mdt>> businessUnitDataMap;
    @TestVisible
    private String objectName;
    private Map<String,Map<Id,sObject>> oldBusinessRecordMap;
    private Map<String,Map<Id,sObject>> newBusinessRecordMap;
    private Map<String,List<sObject>> businessMap;
    private Map<String,String> serviceClassMap;
    @TestVisible
    private List<Business_Unit_Data__mdt> businessUnitDataList;
    @TestVisible
    private TriggerContext context;
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        businessUnitDataMap=new Map<String,List<Business_Unit_Data__mdt>>();
        for(Business_Unit_Data__mdt bu : Business_Unit_Data__mdt.getAll().values()){
            if(!businessUnitDataMap.containsKey(bu.Object__c)){
                businessUnitDataMap.put(bu.Object__c,new List<Business_Unit_Data__mdt>());
            }
            businessUnitDataMap.get(bu.Object__c).add(bu);                                
        }
    }
    // constructor
    public AUSF_TriggerHandler() {

    this.setTriggerContext();
    }

    /***************************************
    * public instance methods
    ***************************************/
    // main method that will be called during execution
        public void run(String objName, String disableField) {
        if(!validateRun()) {
            return;
        }
        if(getTriggerDisabledValue(disableField)){
            return;
        }
        this.objectName=objName;
        fetchBusinessUnitData();
        if(!this.businessUnitDataList.isEmpty()){
            populateBusinessUnitMaps();
        }
        addToLoopCount();
        // dispatch to the correct handler method
        switch on this.context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    /**
    * To set the max run count for the current handler 
    * @param  max   maximum count for consecutive trigger runs
    */
    public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
        if(!AUSF_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            AUSF_TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            AUSF_TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    /**
    * To clear the max run count for the current handler 
    * @param     none
    * @return    none
    */
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /***************************************
     * public static methods
     ***************************************/
    public static void bypass(String handlerName) {
        AUSF_TriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        AUSF_TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return AUSF_TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        AUSF_TriggerHandler.bypassedHandlers.clear();
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(AUSF_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = AUSF_TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = AUSF_TriggerHandler.loopCountMap.get(handlerName).max;
                throw new AUSF_TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new AUSF_TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        return !AUSF_TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private String getHandlerName() {
        return this.toString().substringBefore(':');
    }

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
            (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
            (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
            (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
            (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
            (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
            (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
            (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    /**
    * To fetch the custom metdata records for business units
    * @param     none
    * @return    none      
    */
    private void fetchBusinessUnitData(){
        if(businessUnitDataMap.containsKey(this.objectName)){
            this.businessUnitDataList=businessUnitDataMap.get(this.objectName);
        }else{
            this.businessUnitDataList=new List<Business_Unit_Data__mdt> ();
        }
        this.serviceClassMap=new Map<String,String>();
        for (Business_Unit_Data__mdt objBU : this.businessUnitDataList) {
            if (objBU.Business_Unit_Name__c == 'Default'){
                continue;
            }
            this.serviceClassMap.put(objBU.Business_Unit_Name__c,objBU.Apex_Class__c);
        }
    }

    /**
    * To check whether the trigger is disabled or not
    * @param   fieldName
    * @return  True if trigger is disabled, otherwise False
    */
    private Boolean getTriggerDisabledValue(String fieldName){
        Boolean boolToReturn=(Boolean)Trigger_Deactivation_Settings__c.getInstance().get(fieldName);
        return (boolToReturn==null)?false:boolToReturn;
    }

    /**
    * To populate the business unit record maps based on trigger context
    * @param     none
    * @return    none      
    */
    @TestVisible
    private void populateBusinessUnitMaps(){
        try{
            this.oldBusinessRecordMap=new Map<String,Map<Id,sObject>>();
            this.newBusinessRecordMap=new Map<String,Map<Id,sObject>>();
            this.businessMap=new Map<String,List<sObject>>();
            if(this.businessUnitDataList.isEmpty()){
                throw new AUSF_TriggerHandlerException('No business units present.');
            }
            if(this.businessUnitDataList.size()==1 && this.businessUnitDataList[0].Business_Unit_Name__c == 'Default'){
                handleDefaultType();
                return;
            }
            List<String> buLogicFields = new List<String>();
            if (this.businessUnitDataList[0] != null && this.businessUnitDataList[0].BU_Logic_Fields__c != null) {
                if (this.businessUnitDataList[0].BU_Logic_Fields__c.contains(',')) {
                    buLogicFields = this.businessUnitDataList[0].BU_Logic_Fields__c.split(',');
                } else {
                    buLogicFields.add(this.businessUnitDataList[0].BU_Logic_Fields__c);
                }
            }

            Map<String,List<sObject>> businessUnitMap=new Map<String,List<sObject>>();
            Map<String,String> buValueToBuNameMap=new Map<String,String>();
            for(Business_Unit_Data__mdt objBU:this.businessUnitDataList){
                if(objBU.Business_Unit_Name__c=='Default' && !Test.isRunningTest()){
                    continue;
                }
                this.businessMap.put(objBU.Business_Unit_Name__c,new List<sObject>());
                this.oldBusinessRecordMap.put(objBU.Business_Unit_Name__c,new Map<Id,sObject>());
                this.newBusinessRecordMap.put(objBU.Business_Unit_Name__c,new Map<Id,sObject>());
                buValueToBuNameMap.put(objBU.BU_Logic_Values__c,objBU.Business_Unit_Name__c);
            }
            List<sObject> newTriggerRecordList=Trigger.new != null? Trigger.new:new List<sObject>();
            List<sObject> oldTriggerRecordList=Trigger.old != null? Trigger.old:new List<sObject>();
            for(sObject sObj:newTriggerRecordList){
                String recordValueString='';
                for(String objFld:buLogicFields){
                    String fieldVal='';
                    if(objFld.contains('RecordType.')){
                        fieldVal=getRecordTypeName(objFld,(Id)sObj.get('RecordTypeId'));
                    }else{
                        fieldVal=String.valueOf(sObj.get(objFld));
                    }
                    recordValueString+=(recordValueString=='')?fieldVal:(','+fieldVal);
                }
                String buName=buValueToBuNameMap.get(recordValueString);
                if (this.businessMap.get(buName) != null) {
                    this.businessMap.get(buName).add(sObj);
                }
                if (this.newBusinessRecordMap.get(buName) != null) {
                    this.newBusinessRecordMap.get(buName).put((Id)sObj.get('Id'),sObj);
                }
            }
            for(sObject sObj:oldTriggerRecordList){
                String recordValueString='';
                for(String objFld:buLogicFields){
                    String fieldVal='';
                    if(objFld.contains('RecordType.')){
                        fieldVal=getRecordTypeName(objFld,(Id)sObj.get('RecordTypeId'));
                    }else{
                        fieldVal=String.valueOf(sObj.get(objFld));
                    }
                    recordValueString+=(recordValueString=='')?fieldVal:(','+fieldVal);
                }
                String buName=buValueToBuNameMap.get(recordValueString);
                if (this.oldBusinessRecordMap.get(buName) != null) {
                    this.oldBusinessRecordMap.get(buName).put((Id)sObj.get('Id'),sObj);
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.Error,'populateBusinessUnitMaps Exception-> '+e.getLineNumber());
        }
    }

    /**
    * To get the custom metadata records for business units
    * @param     none
    * @return    list of all the custom metadata type records for the current object      
    */
    @TestVisible
    public List<Business_Unit_Data__mdt> getBusinessUnitData(){
        return this.businessUnitDataList;
    }

    /**
    * To get the trigger.oldMap for passed in business unit
    * @param    businessUnitName    name of the business unit to fetch the records for   
    * @return                       trigger.oldMap for the passed in business unit      
    */
    public Map<Id,sObject> getBusinessUnitOldMap(String businessUnitName){
        if(!this.oldBusinessRecordMap.containsKey(businessUnitName)){
            //throw new TriggerHandlerException('Business Unit not found.');
            return new Map<Id,sObject>();
        }
        return this.oldBusinessRecordMap.get(businessUnitName);
    }

    /**
    * To get the trigger.newMap for passed in business unit
    * @param    businessUnitName    name of the business unit to fetch the records for   
    * @return                       trigger.newMap for the passed in business unit      
    */
    public Map<Id,sObject> getBusinessUnitNewMap(String businessUnitName){
        if(!this.newBusinessRecordMap.containsKey(businessUnitName)){
            return new Map<Id,sObject>();
        }
        return this.newBusinessRecordMap.get(businessUnitName);
    }

    /**
    * To get the trigger.new for passed in business unit
    * @param    businessUnitName    name of the business unit to fetch the records for   
    * @return                       trigger.new for the passed in business unit      
    */
    public List<sObject> getBusinessUnitNewList(String businessUnitName){
        if(!this.businessMap.containsKey(businessUnitName)){
            return new List<sObject>();
        }
        return this.businessMap.get(businessUnitName);
    }


    /***************************************
     * context methods
     ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
    private Integer max;
    private Integer count;

    public LoopCount() {
        this.max = 5;
        this.count = 0;
    }

    public LoopCount(Integer max) {
        this.max = max;
        this.count = 0;
    }

    public Boolean increment() {
        this.count++;
        return this.exceeded();
    }

    public Boolean exceeded() {
        return this.max >= 0 && this.count > this.max;
    }

    public Integer getMax() {
        return this.max;
    }

    public Integer getCount() {
        return this.count;
    }

    public void setMax(Integer max) {
        this.max = max;
    }
    }

    /**
    * To handle the case of object with single type of records
    * @param     none
    * @return    none      
    */
    @TestVisible
    private void handleDefaultType(){
        Business_Unit_Data__mdt defaultObj=this.businessUnitDataList[0];
        this.businessMap.put(defaultObj.Business_Unit_Name__c,new List<sObject>());
        this.oldBusinessRecordMap.put(defaultObj.Business_Unit_Name__c,new Map<Id,sObject>());
        this.newBusinessRecordMap.put(defaultObj.Business_Unit_Name__c,new Map<Id,sObject>());
        this.serviceClassMap.put(defaultObj.Business_Unit_Name__c,defaultObj.Apex_Class__c);
        List<sObject> newTriggerRecordList=Trigger.new != null?Trigger.new:new List<sObject>();
        List<sObject> oldTriggerRecordList=Trigger.old != null?Trigger.old:new List<sObject>();
        for(sObject sObj:newTriggerRecordList){
            this.businessMap.get(defaultObj.Business_Unit_Name__c).add(sObj);
            this.newBusinessRecordMap.get(defaultObj.Business_Unit_Name__c).put((Id)sObj.get('Id'),sObj);
        }
        for(sObject sObj:oldTriggerRecordList){
            this.oldBusinessRecordMap.get(defaultObj.Business_Unit_Name__c).put((Id)sObj.get('Id'),sObj);
        }
    }

    /**
    * To get all the business unit names
    * @param    none
    * @return   set of all business unit names present in custom metadata type for the current object
    */
    public Set<String> getBusinessUnitNames(){
        return this.newBusinessRecordMap.keySet();
    }

    /**
    * To get the apex service class for passed in business unit
    * @param    businessUnitName    name of the business unit to fetch the records for   
    * @return                       name of the apex service class for the passed in business unit      
    */
    public String getServiceClassName(String businessUnitName){
        if(!this.serviceClassMap.containsKey(businessUnitName)){
            throw new AUSF_TriggerHandlerException('Business Unit not found.');
        }
        return this.serviceClassMap.get(businessUnitName);
    }

    /**
    * To get the name of the record type
    * @param     fieldName
    * @param     recordTypeId
    * @return    name of the recordtype      
    */
    @TestVisible
    private String getRecordTypeName(String fieldName, Id recordTypeId){
        if(fieldName=='RecordType.DeveloperName'){
            return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
        }else if(fieldName=='RecordType.Name'){
            return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        }
        return null;
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
    BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
    AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
    AFTER_UNDELETE
    }

    // exception class
    public class AUSF_TriggerHandlerException extends Exception {}

}