import Foundation

class APIService {
    
    static func uploadMedicalDocumentAndFetchDetails(medicalDocument: MedicalDocument, completion: @escaping ([String: [BasicMedicalTestRecordv1]]?, Error?) -> Void) {
        
        // API endpoint
        var useProdUrl = false
        var urlString = useProdUrl ? "https://backend.brainsphere.in/biomarker_report_analyser" : "http://localhost:3000/biomarker_report_analyser"
        guard let url = URL(string: urlString) else { return }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Generate the boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the multipart form data
        var body = Data()
        
        // Add credentials
        let credentials = "2930hrifnef43983hr@9RHIOWWN"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"credentials\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(credentials)\r\n".data(using: .utf8)!)
        
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
}
