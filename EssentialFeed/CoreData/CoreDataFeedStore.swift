//
//  FeedStoreSpecsCoreData.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 10/10/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	public static let modelName = "FeedStore"
	public static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	public struct ModelNotFound: Error {
		public let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	deinit {
		cleanUpReferencesToPersistentStores()
	}

	private func cleanUpReferencesToPersistentStores() {
		context.performAndWait {
			let coordinator = self.container.persistentStoreCoordinator
			try? coordinator.persistentStores.forEach(coordinator.remove)
		}
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform { [unowned self] in
			do {
				if let cache = try ManagedCache.fetchAllManagedCache(in: context).first {
                    completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))

				} else {
                    completion(.success(.none))
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [unowned self] in
			do {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.feedImages(from: feed, in: context)

				try context.save()
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform { [unowned self] in
			do {
				_ = try ManagedCache.fetchAllManagedCache(in: context).map(context.delete).map(context.save)
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}
}

extension CoreDataFeedStore {
	@objc(ManagedCache)
	private class ManagedCache: NSManagedObject {
		@NSManaged var timestamp: Date
		@NSManaged var feed: NSOrderedSet

		static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
			_ = try fetchAllManagedCache(in: context).map(context.delete)
			return ManagedCache(context: context)
		}

		var localFeed: [LocalFeedImage] {
			return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
		}

		static func fetchAllManagedCache(in context: NSManagedObjectContext) throws -> [ManagedCache] {
			let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
			request.returnsObjectsAsFaults = false
			return try context.fetch(request)
		}
	}
}

extension CoreDataFeedStore {
	@objc(ManagedFeedImage)
	private class ManagedFeedImage: NSManagedObject {
		@NSManaged var id: UUID
		@NSManaged var imageDescription: String?
		@NSManaged var location: String?
		@NSManaged var url: URL
		@NSManaged var cache: ManagedCache

		static func feedImages(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
			return NSOrderedSet(array: localFeed.map { local in
				let managed = ManagedFeedImage(context: context)
				managed.id = local.id
				managed.imageDescription = local.description
				managed.location = local.location
				managed.url = local.url
				return managed
			})
		}

		var local: LocalFeedImage {
			return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
		}
	}
}
