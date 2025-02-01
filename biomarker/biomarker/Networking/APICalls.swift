import Foundation

class APIService {
    
    static func uploadMedicalDocumentAndFetchDetails(medicalDocument: MedicalDocument, isScannedDocument: Bool, completion: @escaping ([String: [BasicMedicalTestRecordv1]]?, Error?) -> Void) {
        
        // API endpoint
        let useProdUrl = true
        let urlString = useProdUrl ? "https://backend.brainsphere.in/biomarker_report_analyser" : "http://localhost:3000/biomarker_report_analyser"
        guard let url = URL(string: urlString) else {
            print("/uploadMedicalDocumentAndFetchDetails: invalid url")
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Generate the boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the multipart form data
        var body = Data()
        
        // Add credentials and isScannedDocument
        let credentials = "2930hrifnef43983hr@9RHIOWWN"
        let isScannedDocument = isScannedDocument ? "yes" : "no"

        // Append boundary and form data for credentials
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"credentials\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(credentials)\r\n".data(using: .utf8)!)

        // Append boundary and form data for isScannedDocument
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"isscanneddocument\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(isScannedDocument)\r\n".data(using: .utf8)!)

        // Add the PDF file data
        let pdfUrl = medicalDocument.pdfDocumentUrl
        if let pdfData = try? Data(contentsOf: pdfUrl) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"medical_document.pdf\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
            body.append(pdfData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Start the URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            // Parse the JSON response
            /*
            do {
                let decoder = JSONDecoder()
                let records = try decoder.decode([String: [BasicMedicalTestRecordv1]].self, from: data)
                completion(records, nil)
            } catch {
                completion(nil, error)
            }
            */
            
            // Decode the JSON response
            do {
                let decoder = JSONDecoder()
                
                // First, decode the outer structure with 'message' and 'results' as a string
                struct ResponseData: Decodable {
                    let message: String
                    let results: String // Capture the results as a string first
                }
                
                let responseData = try decoder.decode(ResponseData.self, from: data)
                print("/uploadMedicalDocumentAndFetchDetails: message: \(responseData.message)")
                
                // Now decode the 'results' string into the actual dictionary
                let resultsData = responseData.results.data(using: .utf8)! // Convert to Data
                let resultsDecoder = JSONDecoder()
                let results = try resultsDecoder.decode([String: [BasicMedicalTestRecordv1]].self, from: resultsData)
                
                // Completion with the actual results
                completion(results, nil)
                
            } catch {
                print("Error fetching records:", error)
                completion(nil, error)
            }

            
        }
        task.resume()
    }
    
    ///SUPPLEMENT ANALYSER USING GPT
    

    // Function to call the API
   static func generateSupplementReportWithLLM(supplementInformation: String, completion: @escaping (Bool, [String: Any]?) -> Void) {
        
        
        // API endpoint
        let useProdUrl = false
        let urlString = useProdUrl ? "https://backend.brainsphere.in/biomarker-supplement-analyser" : "http://localhost:3000/biomarker-supplement-analyser"
        guard let url = URL(string: urlString) else {
            print("/generateSupplementReportWithLLM: invalid url")
            completion(false, nil)
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
       let credentials = "2930hrifnef4df3983hr@9RHIOWWN"
        // Encode the supplement information to JSON
        // Set the HTTP body directly from the JSON string
       // Create the JSON body on the fly
          let payload: [String: Any] = [
              "supplementinformation": supplementInformation,
              "credentials": credentials
          ]
       
       do {
               // Convert the dictionary to JSON data
               let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
               
               // Set the httpBody of the request
               request.httpBody = jsonData
           } catch {
               print("Error encoding supplement information: \(error)")
               completion(false, nil)
               return
           }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error making request: \(error)")
                completion(false, nil)
                return
            }
            
            // Check for a valid response
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(response.debugDescription)")
                completion(false, nil)
                return
            }
            
            // Check for data
            guard let data = data else {
                print("No data received")
                completion(false, nil)
                return
            }
            
            // Decode the JSON response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(true, jsonResponse) // Return success and the JSON response
                } else {
                    print("Invalid JSON format")
                    completion(false, nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(false, nil)
            }
        }
        
        // Start the data task
        task.resume()
    }
    ///
}
