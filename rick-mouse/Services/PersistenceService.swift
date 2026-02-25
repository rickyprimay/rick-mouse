//
//  PersistenceService.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import Foundation

final class PersistenceService {

    static let shared = PersistenceService()

    private var configFileURL: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let appDirectory = appSupport.appendingPathComponent(
            AppConstants.appSupportDirectoryName,
            isDirectory: true
        )

        try? FileManager.default.createDirectory(
            at: appDirectory,
            withIntermediateDirectories: true
        )

        return appDirectory.appendingPathComponent(AppConstants.configFileName)
    }

    func loadConfiguration() -> UserConfiguration {
        guard FileManager.default.fileExists(atPath: configFileURL.path) else {
            return UserConfiguration()
        }

        do {
            let data = try Data(contentsOf: configFileURL)
            let decoder = JSONDecoder()
            let config = try decoder.decode(UserConfiguration.self, from: data)
            return config
        } catch {
            print("[PersistenceService] Failed to load configuration: \(error.localizedDescription)")
            return UserConfiguration()
        }
    }

    func saveConfiguration(_ configuration: UserConfiguration) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(configuration)
            try data.write(to: configFileURL, options: .atomic)
        } catch {
            print("[PersistenceService] Failed to save configuration: \(error.localizedDescription)")
        }
    }

    @discardableResult
    func resetConfiguration() -> UserConfiguration {
        try? FileManager.default.removeItem(at: configFileURL)
        let defaults = UserConfiguration()
        saveConfiguration(defaults)
        return defaults
    }
}
