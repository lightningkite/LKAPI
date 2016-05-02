# LKAPI

Microframework for interacting with Alamofire in swift, and defining a strict list of endpoints and how they are used.

[![Circle CI](https://circleci.com/gh/lightningkite/LKAPI.svg?style=svg)](https://circleci.com/gh/lightningkite/LKAPI) 


## Usage

LKAPI lets you define an enum with a list of your endpoints

```swift
enum Router: Routable {
	case Login(email: String, password: String)
	case Signup(name: String, email: String, password: String)
...
```

And map how those endpoints work by defining the HTTPMethod, path, parameters, headers, and even mock data for writing unit tests.

```swift
...
	var method: Alamofire.Method {
		switch self {
		case .Login, .Signup:
			return .POST
		}
	}
	
	var path: NSURL {
		switch self {
		case .Login:
			return NSURL(string: "http://mysuperawesomeapp.com/login")!
		case .Signup:
			return NSURL(string: "http://mysuperawesomeapp.com/signup")!
		}
	}
```

`method` and `path` are required to use the `Routable`. You can also define the `parameters`, `headers` and `mockData`.

To perform one of the requests, call `.request` on the `Routable` object

```swift
Router.Login("My Email", password: "Pass123").request({ data in
	//Handle successful response
}) { error in
	//Handle failure
}
``` 

`API` can also perform a standalone request

```swift
func request(URLRequest: NSURLRequest, success: successCallback?, failure: failureCallback?)
```

## Installation

LKAPI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LKAPI"
```

## Environment

LKAPI includes a class called `Environment`. Environment makes it easy to have multiple targets defined in a project and have different parameters in each. For example, you could have one target for you production API, another for the staging one, and one more for unit tests. The production environment would have the production URL defined, and the staging endpoint would define the staging URL. You can also define a target for Testing which LKAPI will automatically detect and return your mocked data if it exists. Mocked data should be passed to the `Routable` object as the name of a `.json` file that contains the data for an endpoint. The string should only be the name of the file, without '.json'.

To set up an environment, create a file called **`Target-Name`-Env.plist**. Inside of this file you can define different keys and their corresponding values for each target. Make sure the properties match between environment files. For a testing target, create a **description** property with the value **Testing**.

Next, extend `Environment` to customize the properties you have defined. Add a static function for each property you add to the plist other than `description`. For example:

```Swift
extension Environment {
	static var apiBasePath: String {
	    return Environment.environmentDict["apiBasePath"] as? String ?? ""
	}
}
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
    
    ///Optional headers to send up with each request
	var headers: [(String, String)]? {
		switch self {
		case .Login(let email, let password):
			return nil
			
		default:
			if let token = someToken {
				return [("Authorization", "Token \(token)")]
			}
			
			return nil
		}
	}
    
    
    //Only define if you need to customize it. This is returned by default
    ///URLRequest object
    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: path)
        request.HTTPMethod = method.rawValue
        
        if let headers = headers {
			for header in headers {
				request.setValue(header.1, forHTTPHeaderField: header.0)
			}
		}
        
        let encoding = Alamofire.ParameterEncoding.JSON
        
        return encoding.encode(request, parameters: parameters).0
    }
    
    
    ///Mock data to return for tests
    var mockData: String? {
    	return nil
    }
}

```

These router objects will be sent to API class to configure the api request. It is recommended that you extend the API class with your own endpoints. For example, the following is the extension for the login case of the router.

```swift
extension API {
    class func login(email: String, password: String, success: (User -> ())?, failure: failureCallback?) {
        //Do any field validation
        
        Router.Login(email, password: password).request(route, success: { data in
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
