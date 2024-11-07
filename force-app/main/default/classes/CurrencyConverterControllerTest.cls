@IsTest
public class CurrencyConverterControllerTest {

    @IsTest
    static void testGetCurrencyFields() {
        // Retrieve currency fields for a standard object (e.g., Opportunity with Currency fields)
        List<String> currencyFields = CurrencyConverterController.getCurrencyFields('Opportunity');
        
        // Verify that currency fields are returned
        System.assertNotEquals(0, currencyFields.size(), 'Expected currency fields in Opportunity object.');
    }

    @IsTest
    static void testGetTargetCurrencies() {
        // Retrieve the target currencies from custom metadata
        List<String> targetCurrencies = CurrencyConverterController.getTargetCurrencies();
        
        // Verify that target currencies are returned
        System.assertNotEquals(0, targetCurrencies.size(), 'Expected target currencies from Currency__mdt metadata.');
    }

    @IsTest
    static void testGetCurrencyFieldValue() {
        // Set up a test Opportunity record with an Amount (currency field)
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), Amount = 5000);
        insert opp;

        // Retrieve the currency field value using the method
        Decimal currencyValue = CurrencyConverterController.getCurrencyFieldValue('Opportunity', opp.Id, 'Amount');
        
        // Verify that the retrieved amount matches the expected value
        System.assertEquals(5000, currencyValue, 'Expected Amount value to match the Opportunity Amount field.');
    }

    @IsTest
    static void testGetCurrentUserCurrencyIsoCode() {
        // Query the current user’s currency ISO code
        String currencyIsoCode = CurrencyConverterController.getCurrentUserCurrencyIsoCode();
        
        // Verify that a non-null ISO code is returned for the current user
        System.assertNotEquals(null, currencyIsoCode, 'Expected a currency ISO code for the current user.');
    }
}
