/*******************************************************************************************
 * @Name         AUSF_LoanApplicationTriggerHandler
 * @Author       Mohit M.
 * @Description  Handler class for Loan Application Trigger Handler
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Mohit M.            04-July-2024        Initial Creation 
*******************************************************************************************/

public without sharing class AUSF_LoanApplicationTriggerHandler extends AUSF_TriggerHandler{
    /*
    @description - Before Insert
    */
    public override void beforeInsert() {
        for (String eachBU : this.getBusinessUnitNames()) {
            if(!this.getBusinessUnitNewList(eachBU).isEmpty()){
                Type objType = Type.forName(this.getServiceClassName(eachBU));
                ServiceInterface serviceInstance = (ServiceInterface) objType.newInstance();
                serviceInstance.beforeInsert(this.getBusinessUnitNewList(eachBU));
            }            
        }
    }
    
    /*
    @description - After Insert
    */
    public override void afterInsert() {
        for (String eachBU : this.getBusinessUnitNames()) {
            if(!this.getBusinessUnitNewList(eachBU).isEmpty()){
                Type objType = Type.forName(this.getServiceClassName(eachBU));
                ServiceInterface serviceInstance = (ServiceInterface) objType.newInstance();
                serviceInstance.afterInsert(this.getBusinessUnitNewList(eachBU), this.getBusinessUnitNewMap(eachBU));
            }
        }
    }
    
    /*
    @description - Before Update
    */
    public override void beforeUpdate() {
        for (String eachBU : this.getBusinessUnitNames()) {
            if(!this.getBusinessUnitNewList(eachBU).isEmpty()){
                Type objType = Type.forName(this.getServiceClassName(eachBU));
                ServiceInterface serviceInstance = (ServiceInterface) objType.newInstance();
                serviceInstance.beforeUpdate(this.getBusinessUnitNewList(eachBU), this.getBusinessUnitOldMap(eachBU), this.getBusinessUnitNewMap(eachBU));
            }
        }
    }
    
    /*
    @description - After Update
    */
    public override void afterUpdate() {
        for (String eachBU : this.getBusinessUnitNames()) {
            if(!this.getBusinessUnitNewList(eachBU).isEmpty()){
                Type objType = Type.forName(this.getServiceClassName(eachBU));
                ServiceInterface serviceInstance = (ServiceInterface) objType.newInstance();
                serviceInstance.afterUpdate(this.getBusinessUnitNewList(eachBU), this.getBusinessUnitOldMap(eachBU), this.getBusinessUnitNewMap(eachBU));
            }
        }
    }
    
    /*
    @description - Before Delete
    */
    public override void beforeDelete() {
        for (String eachBU : this.getBusinessUnitNames()) {
            Type objType = Type.forName(this.getServiceClassName(eachBU));
            ServiceInterface serviceInstance = (ServiceInterface) objType.newInstance();
            serviceInstance.beforeDelete(this.getBusinessUnitOldMap(eachBU));
        }
    }

    /*
    @description - After Delete
    */
    public override void afterDelete() {
        for (String eachBU : this.getBusinessUnitNames()) {
            Type objType = Type.forName(this.getServiceClassName(eachBU));
            ServiceInterface serviceInstance = (ServiceInterface) objType.newInstance();
            serviceInstance.afterDelete(this.getBusinessUnitOldMap(eachBU));
        }
    }
}