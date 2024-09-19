({
	previewFile: function (component, event, helper) {
		var rec_id = '069C1000003PUnaIAG';
		$A.get('e.lightning:openFiles').fire({
		recordIds: [rec_id]
		});
	}
})