import Foundation
import Combine

struct AuthState {
    let isAuthenticated: Bool
    let user: User?
}

protocol AuthenticationServiceProtocol {
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    func signIn(email: String, password: String) -> AnyPublisher<User, Error>
    func signUp(email: String, password: String, name: String) -> AnyPublisher<User, Error>
    func signOut() -> AnyPublisher<Void, Error>
}

class AuthenticationService: AuthenticationServiceProtocol {
    @Published private var authState = AuthState(isAuthenticated: true, user: nil)
    
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        $authState.eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        // Implementation would make an API call in a real app
        return Future<User, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let user = User(
                    id: "user123",
                    name: "John Doe",
                    email: email,
                    dateOfBirth: nil,
                    gender: nil
                )
                
                self.authState = AuthState(isAuthenticated: true, user: user)
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, name: String) -> AnyPublisher<User, Error> {
        // Implementation would make an API call in a real app
        return Future<User, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let user = User(
                    id: "user123",
                    name: name,
                    email: email,
                    dateOfBirth: nil,
                    gender: nil
                )
                
                self.authState = AuthState(isAuthenticated: true, user: user)
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.authState = AuthState(isAuthenticated: false, user: nil)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
