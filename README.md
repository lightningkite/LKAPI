# LKAPI

[![CI Status](http://img.shields.io/travis/Erik Sargent/LKAPI.svg?style=flat)](https://travis-ci.org/Erik Sargent/LKAPI)
[![Version](https://img.shields.io/cocoapods/v/LKAPI.svg?style=flat)](http://cocoapods.org/pods/LKAPI)
[![License](https://img.shields.io/cocoapods/l/LKAPI.svg?style=flat)](http://cocoapods.org/pods/LKAPI)
[![Platform](https://img.shields.io/cocoapods/p/LKAPI.svg?style=flat)](http://cocoapods.org/pods/LKAPI)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LKAPI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/Lightningkite/LKPodspec.git'

pod "LKAPI"
```

## Setup

The first step in using LKAPI is creating a router. The router will be an enum that responds to the `Routable` protocol. The router will be in charge of defining the API endpoints, the parameters to send to the endpoints, and any mock testing data associated with them. An example router is defined below:

```swift
enum Router: Routable {
    case Login(String, String)
    
    
    ///HTTP Method for the request
    var method: Alamofire.Method {
        switch self {
        case .Login(_):
            return .POST
    }
    
    
    ///Path to the endpoint
    var path: NSURL {
        var pathComponent: String

        switch self {
        case .Login(_):
            pathComponent = "/sessions/"
        }
        
        return NSURL(string: Environment.apiBasePath)!.URLByAppendingPathComponent(pathComponent)
    }
    
    
    ///Optional parameters to send up with each request
    var parameters: [String: AnyObject]? {
        switch self {
        case .Login(let email, let password):
            return ["email": email, "password": password]
        
        default:
            return nil
        }
    }
    
    
    ///URLRequest object
    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: path)
        request.HTTPMethod = method.rawValue
        let encoding = Alamofire.ParameterEncoding.JSON
        
        return encoding.encode(request, parameters: parameters).0
    }
    
    
    ///Mock data to return for tests
    var mockData: AnyObject? {
    	return nil
    }
}

```

These router objects will be sent to API class to configure the api request. It is recommended that you extend the API class with your own endpoints. For example, the following is the extension for the login case of the router.

```swift
extension API {
    class func login(email: String, password: String, success: (User -> ())?, failure: failureCallback?) {
        //Do any field validation
        
        //Create the route object
        let route = Router.Login(email, password)
        
        //Send the request, and handle the response
        request(route, success: { data in
            if let data = data as? [String: AnyObject] {
                let user = User(data: data)
                success?(user)
            }
            else {
                failure?(Failure(error: NetworkError.BadData))
            }
        }, failure: failure)
    }
}
```

It is also recommended that the models are configured so the data from the API can be passed into an initializer for parsing.



## Author

Erik Sargent, erik@lightningkite.com

## License

LKAPI is available under the MIT license. See the LICENSE file for more info.
