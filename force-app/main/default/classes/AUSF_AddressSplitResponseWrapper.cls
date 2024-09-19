/**
 * @author       Pradeep Sharma
 * Class :		 AUSF_AddressSplitResponseWrapper
 * @date         06-Aug-2024
 * @description: Integration response wrapper for AddressSplit utility
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Pradeep Sharma        06-Aug-2024    Initial Version
*/
public class AUSF_AddressSplitResponseWrapper{
    public AUSF_AddressSplitResponseWrapper(){}
    public splitaddress splitaddress;
	public class splitaddress{
	public String locality;
	public String Untagged;
	public String State;
	public String Street;
	public String District;
	public String Complex;
	public String City;
	public String Building;
	public String Landmark;
	public String Floor;
	public Integer Pin;
	public String House;
	public String Care_Of;
	}
}