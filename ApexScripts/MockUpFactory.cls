@isTest
public class MockUpFactory {
	
    // @isTest
    public class PageSettingsViewControllerTest{
        // @testSetup
        public void createData() {
            system.debug('test setup');
        }
        
        // @isTest
        public void itShould() {
            system.debug('test some method');
        }
    }
    
    @isTest
    public static void PageSettingsViewControllerTest_itShould() {
        PageSettingsViewControllerTest testClass = new PageSettingsViewControllerTest();

        // Test Setup
        testClass.createData();

        Test.startTest();
        // Test Method
      	testClass.itShould();

        Test.stopTest();
    }
}