//  OcrComputerVision.swift
//
//  Copyright (c) 2016 Vladimir Danila
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import Foundation


/**
 RequestObject is the required parameter for the OCR API containing all required information to perform a request
 - parameter resource: The path or data of the image or
 - parameter language, detectOrientation: Read more about those [here](https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa)
 */
typealias OCRRequestObject = (resource: Any, language: OCR.Languages, detectOrientation: Bool)


/**
 Title Read text in images
 
 Optical Character Recognition (OCR) detects text in an image and extracts the recognized words into a machine-readable character stream. Analyze images to detect embedded text, generate character streams and enable searching. Allow users to take photos of text instead of copying to save time and effort.
 
 - You can try OCR here: https://www.microsoft.com/cognitive-services/en-us/computer-vision-api
 
 */
class OCR: NSObject {
    
    /// The url to perform the requests on
    let url = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/ocr"
    
    /// Your private API key. If you havn't changed it yet, go ahead!
    let key = CognitiveServicesApiKeys.ComputerVision.rawValue
    
    /// Detectable Languages
    enum Languages: String {
        case Automatic = "unk"
        case ChineseSimplified = "zh-Hans"
        case ChineseTraditional = "zh-Hant"
        case Czech = "cs"
        case Danish = "da"
        case Dutch = "nl"
        case English = "en"
        case Finnish = "fi"
        case French = "fr"
        case German = "de"
        case Greek = "el"
        case Hungarian = "hu"
        case Italian = "it"
        case Japanese = "Ja"
        case Korean = "ko"
        case Norwegian = "nb"
        case Polish = "pl"
        case Portuguese = "pt"
        case Russian = "ru"
        case Spanish = "es"
        case Swedish = "sv"
        case Turkish = "tr"
    }
    
    enum RecognizeCharactersErrors: Error {
        case unknownError
        case imageUrlWrongFormatted
        case emptyDictionary
    }
    
    var wordCoordinates: [String:[String]] = [:]
    var orientation: String = "Up"
    var textAngle: Float = 0.0
    
    /**
     Optical Character Recognition (OCR) detects text in an image and extracts the recognized characters into a machine-usable character stream.
     - parameter requestObject: The required information required to perform a request
     - parameter language: The languange
     - parameter completion: Once the request has been performed the response is returend in the completion block.
     */
    func recognizeCharactersWithRequestObject(_ requestObject: OCRRequestObject, completion: @escaping (_ response: [String:AnyObject]?, _ error: String) -> Void) throws {

        // Generate the url
        let requestUrlString = url + "?language=" + Languages.English.rawValue + "&detectOrientation%20=\(requestObject.detectOrientation)"
        let requestUrl = URL(string: requestUrlString)
        
        
        var request = URLRequest(url: requestUrl!)
        request.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        // Request Parameter
        if let path = requestObject.resource as? String {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"url\":\"\(path)\"}".data(using: String.Encoding.utf8)
        }
        else if let imageData = requestObject.resource as? Data {
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
        }
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            if error != nil{
                print("Error -> \(String(describing: error))")
                completion(nil, (error?.localizedDescription)!)
                return
            }else{
                
                if let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject] {
                    // Hand dict over
                    DispatchQueue.main.async {
                        completion(results,"")
                    }
                }
            }
            
        }
        task.resume()
        
    }
    
	/**
     Returns an Array of Strings extracted from the Dictionary generated from `recognizeCharactersOnImageUrl()`
     - Parameter dictionary: The Dictionary created by `recognizeCharactersOnImageUrl()`.
     - Returns: An String Array extracted from the Dictionary.
     */
    
    
    func extractStringsFromDictionary(_ dictionary: [String : AnyObject]) {
        
        // reset word Coordinates
        wordCoordinates.removeAll()
        
        if let a = dictionary["textAngle"] as? NSNumber{
            textAngle = a.floatValue
        }
        
        if let o = dictionary["orientation"] {
            orientation = o as! String
        }
        
        if dictionary["regions"] != nil {
            
            if let regionsz = dictionary["regions"] as? [AnyObject]{
                for reigons1 in regionsz
                {
                    if let reigons = reigons1 as? [String:AnyObject]
                    {
                        let lines = reigons["lines"] as! NSArray
                        print (lines)
                        for words in lines{
                            
                            if let wordsArr = words as? [String:AnyObject] {
                                if let dictionaryValue = wordsArr["words"] as? [AnyObject] {
                                    
                                    for a in dictionaryValue {
                                        if let z = a as? [String : AnyObject] {
                                            
                                            if let word = z["text"] {
                                                
                                                // last
                                                var strWord = String(describing: word)
                                                let bBox = z["boundingBox"]! as? String
                                                
                                                // cleaning and case handles
                                                if let special = getSpecialCharsIn(Word: strWord){
                                                    for ch in special {
                                                        strWord = strWord.replacingOccurrences(of: String(ch), with: " ")
                                                    }
                                                    let strWords = strWord.split(separator: " ")
                                                    for aWord in strWords {
                                                        if let cleanedWord = getOkayCharsIn(Word: String(aWord)) {
                                                            addThisToDictionary(word: cleanedWord, box: bBox!)
                                                        }
                                                    }
                                                    addThisToDictionary(word: strWord, box: bBox!)
                                                } else if let special = getKeyCharsIn(Word: strWord){
                                                    let strWords = strWord.split(separator: special)
                                                    for aWord in strWords {
                                                        if let cleanedWord = getOkayCharsIn(Word: String(aWord)) {
                                                            addThisToDictionary(word: cleanedWord, box: bBox!)
                                                        }
                                                    }
                                                    addThisToDictionary(word: String(special), box: bBox!)
                                                } else {
                                                    addThisToDictionary(word: strWord, box: bBox!)
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // adds a string to dictionary
    func addThisToDictionary(word strWord: String, box bBox: String) {
        if var existingCoord = wordCoordinates[strWord] {
            existingCoord.append(bBox)
            wordCoordinates[strWord] = existingCoord
        } else {
            let newArray: [String] = [bBox]
            wordCoordinates[strWord] = newArray
        }
    }
    
    // contains alpha numeric plus few extra cases
    func getOkayCharsIn(Word word: String) -> String? {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(word.filter {okayChars.contains($0)})
    }
    
    // If the word contains special characters, return them
    // loops this way cause most words will be smaller than the Set
    func getSpecialCharsIn(Word word: String) -> String? {
        var returnString: String? = nil
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890%$")
        for ch in word{
            if !okayChars.contains(ch) {
                if returnString != nil{
                    returnString!.append(ch)
                } else {
                    returnString = String(ch)
                }
            }
        }
        return returnString
    }
    
    // These are special cases for special searches
    // loops this way cause set will be smaller than the word
    func getKeyCharsIn(Word word: String) -> Character? {
        let keyChars : Set<Character> = Set("%$")
        for ch in keyChars {
            if word.contains(ch){
                return ch
            }
        }
        return nil
    }
    
}
