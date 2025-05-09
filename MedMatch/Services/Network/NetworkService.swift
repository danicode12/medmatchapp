import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case unauthorized
    case notFound
    case serverError
}

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
    func post<T: Decodable, E: Encodable>(endpoint: Endpoint, body: E) -> AnyPublisher<T, NetworkError>
    func put<T: Decodable, E: Encodable>(endpoint: Endpoint, body: E) -> AnyPublisher<T, NetworkError>
    func delete<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]?
    
    init(path: String, queryItems: [URLQueryItem]? = nil) {
        self.path = path
        self.queryItems = queryItems
    }
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(baseURL: URL = URL(string: "https://api.medmatch.com")!,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetch<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { NetworkError.requestFailed($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return Just(data)
                        .decode(type: T.self, decoder: self.decoder)
                        .mapError { error -> NetworkError in
                            .decodingFailed(error)
                        }
                        .eraseToAnyPublisher()
                case 401:
                    return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                case 404:
                    return Fail(error: NetworkError.notFound).eraseToAnyPublisher()
                default:
                    return Fail(error: NetworkError.serverError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func post<T: Decodable, E: Encodable>(endpoint: Endpoint, body: E) -> AnyPublisher<T, NetworkError> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: NetworkError.requestFailed(error)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.requestFailed($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return Just(data)
                        .decode(type: T.self, decoder: self.decoder)
                        .mapError { error -> NetworkError in
                            .decodingFailed(error)
                        }
                        .eraseToAnyPublisher()
                case 401:
                    return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                case 404:
                    return Fail(error: NetworkError.notFound).eraseToAnyPublisher()
                default:
                    return Fail(error: NetworkError.serverError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func put<T: Decodable, E: Encodable>(endpoint: Endpoint, body: E) -> AnyPublisher<T, NetworkError> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: NetworkError.requestFailed(error)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.requestFailed($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return Just(data)
                        .decode(type: T.self, decoder: self.decoder)
                        .mapError { error -> NetworkError in
                            .decodingFailed(error)
                        }
                        .eraseToAnyPublisher()
                case 401:
                    return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                case 404:
                    return Fail(error: NetworkError.notFound).eraseToAnyPublisher()
                default:
                    return Fail(error: NetworkError.serverError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func delete<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.requestFailed($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return Just(data)
                        .decode(type: T.self, decoder: self.decoder)
                        .mapError { error -> NetworkError in
                            .decodingFailed(error)
                        }
                        .eraseToAnyPublisher()
                case 401:
                    return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                case 404:
                    return Fail(error: NetworkError.notFound).eraseToAnyPublisher()
                default:
                    return Fail(error: NetworkError.serverError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

