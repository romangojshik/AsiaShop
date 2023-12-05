//
//  ProfileViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 5.12.23.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
    }

    func setProfile() {
        DatabaseService.shared.setProfile(user: self.profile) { result in
            switch result {
            case .success(let user):
                print(user.name)
            case .failure(let error):
                print("Error")
            }
        }
    }
    
    func getProfile() {
        DatabaseService.shared.getProfile { result in
            switch result {
            case .success(let user):
                self.profile = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
