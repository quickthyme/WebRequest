//
//  ProgressFileDownloadWebRequestDeliveryTests.swift
//  WebRequestTests
//
//  Created by John Heryer on 7/3/19.
//  Copyright © 2019 VML, Inc. All rights reserved.
//

import XCTest
import WebRequest

class ProgressFileDownloadWebRequestDeliveryTests: XCTestCase {

   

    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_zero_bytes_are_written_THEN_percentComplete_is_0() {
        
        let expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_zero_bytes_are_written_THEN_percentComplete_is_0")
        let successfulResponse = HTTPURLResponse(url: URL(string: "test.file")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let urlSession = MockURLSession(configuration: URLSessionConfiguration())
        urlSession.mockResponse = successfulResponse
        let downloadRequest = MockURLSessionDownloadTask(mockSession: urlSession, url: URL(string: "test.file")!)
        let subject =  ProgressFileDownloadWebRequestDelivery(targetURL: URL(string: "test.file")!)
        var testPercent: Int = -99
        var testfilePath: URL?
        let wr = WebRequest(urlString: "https://path/to/pdf.pdf",
                                         method: .GET,
                                         delivery: subject,
                                         onDataReceived: {
                                            (result, request, percentComplete, filePath) in
                                            
                                            print(filePath)
                                            testPercent = percentComplete
                                            testfilePath = filePath
                                            expectation.fulfill()
        })
        
        subject.webRequest = wr;
        subject.urlSession(urlSession, downloadTask: downloadRequest, didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 100)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(testPercent, 0)
            XCTAssertEqual(testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20() {
        
        let expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20")
        let successfulResponse = HTTPURLResponse(url: URL(string: "test.file")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let urlSession = MockURLSession(configuration: URLSessionConfiguration())
        urlSession.mockResponse = successfulResponse
        let downloadRequest = MockURLSessionDownloadTask(mockSession: urlSession, url: URL(string: "test.file")!)
        let subject =  ProgressFileDownloadWebRequestDelivery(targetURL: URL(string: "test.file")!)
        var testPercent: Int = -99
        var testfilePath: URL?
        let wr = WebRequest(urlString: "https://path/to/pdf.pdf",
                            method: .GET,
                            delivery: subject,
                            onDataReceived: {
                                (result, request, percentComplete, filePath) in
                                
                                print(filePath)
                                testPercent = percentComplete
                                testfilePath = filePath
                                expectation.fulfill()
        })
        
        subject.webRequest = wr;
        subject.urlSession(urlSession, downloadTask: downloadRequest, didWriteData: 0, totalBytesWritten: 20, totalBytesExpectedToWrite: 100)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(testPercent, 20)
            XCTAssertEqual(testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_91_bytes_are_written_out_of_100_THEN_percentComplete_is_20() {
        
        let expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20")
        let successfulResponse = HTTPURLResponse(url: URL(string: "test.file")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let urlSession = MockURLSession(configuration: URLSessionConfiguration())
        urlSession.mockResponse = successfulResponse
        let downloadRequest = MockURLSessionDownloadTask(mockSession: urlSession, url: URL(string: "test.file")!)
        let subject =  ProgressFileDownloadWebRequestDelivery(targetURL: URL(string: "test.file")!)
        var testPercent: Int = -99
        var testfilePath: URL?
        let wr = WebRequest(urlString: "https://path/to/pdf.pdf",
                            method: .GET,
                            delivery: subject,
                            onDataReceived: {
                                (result, request, percentComplete, filePath) in
                                
                                print(filePath)
                                testPercent = percentComplete
                                testfilePath = filePath
                                expectation.fulfill()
        })
        
        subject.webRequest = wr;
        subject.urlSession(urlSession, downloadTask: downloadRequest, didWriteData: 0, totalBytesWritten: 91, totalBytesExpectedToWrite: 100)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(testPercent, 91)
            XCTAssertEqual(testfilePath!.absoluteString, "test.file")
        }
    }

    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_THEN_percentComplete_is_20() {
        
        let expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20")
        let successfulResponse = HTTPURLResponse(url: URL(string: "test.file")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let urlSession = MockURLSession(configuration: URLSessionConfiguration())
        urlSession.mockResponse = successfulResponse
        let downloadRequest = MockURLSessionDownloadTask(mockSession: urlSession, url: URL(string: "test.file")!)
        let subject =  ProgressFileDownloadWebRequestDelivery(targetURL: URL(string: "test.file")!)
        var testPercent: Int = -99
        var testfilePath: URL?
        let wr = WebRequest(urlString: "https://path/to/pdf.pdf",
                            method: .GET,
                            delivery: subject,
                            onDataReceived: {
                                (result, request, percentComplete, filePath) in
                                
                                print(filePath)
                                testPercent = percentComplete
                                testfilePath = filePath
                                expectation.fulfill()
        })
        
        subject.webRequest = wr;
        subject.urlSession(urlSession, downloadTask: downloadRequest, didFinishDownloadingTo: URL(string: "test.file")!)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(testPercent, 100)
            XCTAssertEqual(testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_AND_response_is_not_200_percentComplete_is_0() {
        
        let expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20")
        let successfulResponse = HTTPURLResponse(url: URL(string: "test.file")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let urlSession = MockURLSession(configuration: URLSessionConfiguration())
        urlSession.mockResponse = successfulResponse
        let downloadRequest = MockURLSessionDownloadTask(mockSession: urlSession, url: URL(string: "test.file")!)
        let subject =  ProgressFileDownloadWebRequestDelivery(targetURL: URL(string: "test.file")!)
        var testPercent: Int = -99
        var testfilePath: URL?
        let wr = WebRequest(urlString: "https://path/to/pdf.pdf",
                            method: .GET,
                            delivery: subject,
                            onDataReceived: {
                                (result, request, percentComplete, filePath) in
                                
                                print(filePath)
                                testPercent = percentComplete
                                testfilePath = filePath
                                expectation.fulfill()
        })
        
        subject.webRequest = wr;
        subject.urlSession(urlSession, downloadTask: downloadRequest, didFinishDownloadingTo: URL(string: "test.file")!)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(testPercent, 0)
            XCTAssertEqual(testfilePath!.absoluteString, "test.file")
        }
    }
    
    
}
