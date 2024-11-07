public with sharing class CurrencyConverterController {
    @AuraEnabled(cacheable=true)
    public static List<String> getCurrencyFields(String objectName) {
        List<String> currencyFields = new List<String>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fields = sObjectType.getDescribe().fields.getMap();

        for (Schema.SObjectField field : fields.values()) {
            Schema.DisplayType fieldType = field.getDescribe().getType();
            if (fieldType == Schema.DisplayType.Currency) {
                currencyFields.add(field.getDescribe().getName());
            }
        }
        return currencyFields;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTargetCurrencies() {
        List<String> picklistValues = new List<String>();

        Schema.SObjectType currencySettingsType = Schema.getGlobalDescribe().get('Currency__mdt');
        Schema.DescribeFieldResult currencyCodeField = currencySettingsType.getDescribe().fields.getMap().get('Currency__c').getDescribe();

        for (Schema.PicklistEntry entry : currencyCodeField.getPicklistValues()) {
            picklistValues.add(entry.getLabel()); 
        }

        return picklistValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getCurrencyFieldValue(String objectName, String recordId, String currencyFieldName) {
        String query = 'SELECT ' + currencyFieldName + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
    
    SObject record = Database.query(query);

    if (record != null) {
        return (Decimal) record.get(currencyFieldName);
    }
    return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserCurrencyIsoCode() {
        String userCurrencyIsoCode = [SELECT CurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId()].CurrencyIsoCode;
        return userCurrencyIsoCode;
    }
}