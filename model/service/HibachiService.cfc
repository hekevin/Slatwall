component accessors="true" extends="Slatwall.org.Hibachi.HibachiService" {

	public any function getSlatwallScope() {
		return getHibachiScope();
	} 
	
	// @hint returns true or false based on an entityName, and checks if that entity has an extended attribute with that attributeCode
	public boolean function getEntityHasAttributeByEntityName( required string entityName, required string attributeCode ) {
		if(listFindNoCase(getAttributeService().getAttributeCodesListByAttributeSetType( "ast#getProperlyCasedShortEntityName(arguments.entityName)#" ), arguments.attributeCode)) {
			return true;
		}
		return false; 
	}
	
	public boolean function delete(required any entity){
			
		// If the entity Passes validation
		if(arguments.entity.isDeletable()) {
			
			// Remove any Many-to-Many relationships
			arguments.entity.removeAllManyToManyRelationships();
			
			getService("settingService").removeAllEntityRelatedSettings( entity=arguments.entity );
			
			// Call delete in the DAO
			getHibachiDAO().delete(target=arguments.entity);
			
			// Return that the delete was sucessful
			return true;
			
		}
			
		// Setup ormHasErrors because it didn't pass validation
		getHibachiScope().setORMHasErrors( true );

		return false;
	}
}