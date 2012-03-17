/*

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component extends="BaseService" {
	
	public any function init() {
		if(!encryptionKeyExists()){
			createEncryptionKey();
		}
		return super.init();
	}
	
	public string function encryptValue(required string value) {
		return encrypt(arguments.value,getEncryptionKey(),getEncrptionAlgorithm(),getEncrptionEncoding());
	}

	public string function decryptValue(required string value) {
		return decrypt(arguments.value,getEncryptionKey(),getEncrptionAlgorithm(),getEncrptionEncoding());
	}
	
	public string function createEncryptionKey() {
		var	theKey = generateSecretKey(getEncrptionAlgorithm(),getEncrptionKeySize());
		storeEncryptionKey(theKey);
		return theKey;
	}
	
	public string function getEncrptionAlgorithm() {
		return "AES";	
	}
	
	public string function getEncrptionEncoding() {
		return "Base64";	
	}
	
	public string function getEncryptionKey() {
		var encryptionFileData = fileRead(getEncryptionKeyFilePath());
		var encryptionInfoXML = xmlParse(encryptionFileData);
		return encryptionInfoXML.crypt.key.xmlText;
	}
	
	private string function getEncrptionKeySize() {
		return setting("advanced_encryptionKeySize") NEQ "" ? setting("advanced_encryptionKeySize") : "128";	
	}
	
	private string function getEncryptionKeyFilePath() {
		return getEncryptionKeyLocation() & getEncryptionKeyFileName();
	}
	
	private string function getEncryptionKeyLocation() {
		return setting("advanced_encryptionKeyLocation") NEQ "" ? setting("advanced_encryptionKeyLocation") : "#getSlatwallRootDirectory()#/config/";
	}
	
	private string function getEncryptionKeyFileName() {
		return "key.xml.cfm";
	}
	
	private boolean function encryptionKeyExists() {
		return fileExists(getEncryptionKeyFilePath());
	}
	
	private void function storeEncryptionKey(required string key) {
		var theKey = "<crypt><key>#arguments.key#</key></crypt>";
		fileWrite(getEncryptionKeyFilePath(),theKey);
	}
	
}