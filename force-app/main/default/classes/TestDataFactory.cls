public with sharing class TestDataFactory {
    public static List<Account> createAccount(Integer numberOfAccounts, String Type) {
        List<Account> accounts = new List<Account>();
        for(Integer i=0; i<numberOfAccounts; i++) {
            Account acc = new Account();
            acc.Name = 'Thomas' + i;
            acc.Type = Type;
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }
}