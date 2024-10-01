//
//  APICalls.swift
//  biomarker
//
//  Created by sachin jeph on 01/10/24.
//

import Foundation

class APIService {
    
    
    //this will take in a medical record document and return a list of BasicMedicalTestRecordv1
    static func fetchMedicalRecords(medicalDocument: MedicalDocument,completion: @escaping ([String: [BasicMedicalTestRecordv1]]?, Error?) -> Void) {
        
        //we need to upload the medical document present in the medical document, as of now that will be a pdf
        
        // Prepare the URL and request
        guard let url = URL(string: "https://backend.brainsphere.in/biomarker_report_analyser") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Optionally, add request headers or body as required by the API
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Start the URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            // Decode the JSON response
            do {
                let decoder = JSONDecoder()
                let records = try decoder.decode([String: [BasicMedicalTestRecordv1]].self, from: data)
                completion(records, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
