public with sharing class HelloWorld {
    
    /**
     * Returns a greeting message
     * @return String greeting message
     */
    public static String sayHello() {
        return 'Hello World!';
    }
    
    /**
     * Returns a personalized greeting
     * @param name The name to greet
     * @return String personalized greeting message
     */
    public static String sayHelloToName(String name) {
        if (String.isBlank(name)) {
            return 'Hello World!';
        }
        return 'Hello ' + name + '!';
    }
    
    /**
     * Gets the current user's greeting
     * @return String greeting with current user's name
     */
    public static String sayHelloToCurrentUser() {
        User currentUser = [SELECT FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String fullName = currentUser.FirstName + ' ' + currentUser.LastName;
        return sayHelloToName(fullName);
    }
    
    /**
     * Counts the number of greetings
     * @param numberOfGreetings Number of times to say hello
     * @return List of greeting strings
     */
    public static List<String> sayMultipleHellos(Integer numberOfGreetings) {
        List<String> greetings = new List<String>();
        
        if (numberOfGreetings == null || numberOfGreetings <= 0) {
            greetings.add('Hello World!');
            return greetings;
        }
        
        for (Integer i = 1; i <= numberOfGreetings; i++) {
            greetings.add('Hello #' + i + '!');
        }
        
        return greetings;
    }
}