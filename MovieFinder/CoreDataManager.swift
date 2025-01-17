//
//  CoreDataManager.swift
//  MovieFinder
//
//  Created by Yosif Iliev on 18.09.19.
//  Copyright © 2019 Yosif Iliev. All rights reserved.
//

import Foundation
import CoreData

extension Notification.Name {
    static let favouriteAdded = Notification.Name("favouriteAdded")
    static let favouriteDeleted = Notification.Name("favouriteRemoved")
}

final class CoreDataManager {

    // MARK: - Properties

    static let shared = CoreDataManager()


    // MARK: - Initialization

    private init() {}

    private func notify(notification: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: notification, object: object)
    }


    // MARK: - Public

    func saveFavourite(movie: Movie, completion: ((_ result: Result<Bool, Error>) -> Void)? = nil) {

        if let _ = fetchFavourite(for: Int64(movie.id), type: .movie) {
            return
        }

        backgroundContext.perform {

            let favourite = Favourite(context: self.backgroundContext)
            favourite.type = FavouriteType.movie.rawValue
            favourite.id = Int64(movie.id)
            favourite.title = movie.title
            favourite.overview = movie.overview
            favourite.posterPath = movie.posterPath
            favourite.date = movie.releaseDate
            favourite.voteAverage = movie.voteAverage ?? 0.0
            favourite.genreIDs = movie.genreIDs
            self.saveOrRollback()
        }
        notify(notification: Notification.Name.favouriteAdded, object: movie)
    }

    func saveFavourite(tvShow: TVShow, completion: ((_ result: Result<Bool, Error>) -> Void)? = nil) {

        if let _ = fetchFavourite(for: Int64(tvShow.id), type: .tvShow) {
            return
        }

        backgroundContext.perform {

            let favourite = Favourite(context: self.backgroundContext)
            favourite.type = FavouriteType.tvShow.rawValue
            favourite.id = Int64(tvShow.id)
            favourite.title = tvShow.title
            favourite.overview = tvShow.overview
            favourite.posterPath = tvShow.posterPath
            favourite.date = tvShow.firstAirDate
            favourite.voteAverage = tvShow.voteAverage ?? 0.0
            favourite.genreIDs = tvShow.genreIDs
            self.saveOrRollback()
        }
        notify(notification: Notification.Name.favouriteAdded, object: tvShow)
    }

    func deleteFavourite(movie: Movie) {

        guard let favourite = fetchFavourite(for: Int64(movie.id), type: .movie) else { return }
        remove(with: favourite.objectID)
        notify(notification: Notification.Name.favouriteDeleted, object: favourite.getMovie())
    }


    func deleteFavourite(tvShow: TVShow) {

        guard let favourite = fetchFavourite(for: Int64(tvShow.id), type: .tvShow) else { return }
        remove(with: favourite.objectID)
        notify(notification: Notification.Name.favouriteDeleted, object: favourite.getTVShow())
    }

    func favouriteExists(movie: Movie) -> Bool {
        return fetchFavourite(for: Int64(movie.id), type: .movie) != nil
    }

    func favouriteExists(tvShow: TVShow) -> Bool {
        return fetchFavourite(for: Int64(tvShow.id), type: .tvShow) != nil
    }

    func getFavourites() -> [Any] {

        var favourites = [Any]()
        let request: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        if let results = try? persistentContainer.viewContext.fetch(request) {
            results.forEach { (favourite) in
                if favourite.type == FavouriteType.movie.rawValue {
                    favourites.append(favourite.getMovie())
                } else {
                    favourites.append(favourite.getTVShow())
                }
            }
        }
        return favourites
    }


    // MARK: - Private

    private func fetchFavourite(for id: Int64, type: FavouriteType) -> Favourite? {
        assert(Thread.isMainThread, "Must be called on main thread because of core data view context")

        let request: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        let idPredicate = NSPredicate(format: "id == %i", id)
        let typePredicate = NSPredicate(format: "type == %i", type.rawValue)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [idPredicate, typePredicate])
        request.predicate = predicate
        let results = try? persistentContainer.viewContext.fetch(request)
        return results?.first
    }

    private func remove(with objectID: NSManagedObjectID, completion: ((_ result: Result<Bool, Error>) -> Void)? = nil) {
        backgroundContext.perform {
            let object = self.backgroundContext.object(with: objectID)
            self.backgroundContext.delete(object)
            self.saveOrRollback(completion: completion)
        }
    }

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieFinder")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    //lazy var context = persistentContainer.viewContext

    private lazy var backgroundContext: NSManagedObjectContext = {
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()

    // MARK: - Core Data Saving support

    private func saveOrRollback(completion: ((_ result: Result<Bool, Error>) -> Void)? = nil) {
        do {
            try backgroundContext.save()
            completion?(.success(true))
        } catch {
            backgroundContext.rollback()
            completion?(.failure(error))
        }
    }

    func save() {
        saveOrRollback()
    }
}
