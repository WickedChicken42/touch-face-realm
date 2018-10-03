//
//  Note.swift
//  touch-face
//
//  Created by James Ullom on 9/26/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    
    // Data from our database
    public private(set) var noteUUID: UUID {
        get { return UUID(uuidString: noteUUIDRaw)! }
        set { noteUUIDRaw = newValue.uuidString }
    }
    @objc dynamic public private(set) var message: String = ""
    @objc dynamic public private(set) var noteTimestamp: NSDate = NSDate()
    public private(set) var lockStatus: LockStatus {
        get { return LockStatus(rawValue: lockStatusRaw)! }
        set { lockStatusRaw = newValue.rawValue }
    }

    // Private properties used by Realm for storage
    @objc dynamic private var noteUUIDRaw: String = NEW_UUID!.uuidString
    @objc dynamic private var lockStatusRaw: String = LockStatus.unlocked.rawValue
        
    
    // Holds the data object for reading and saving
    //public private(set) var noteData: NoteData?

    // Added to tell Realm who my Primary Key in the DB is
    override class func primaryKey() -> String {
        return "noteUUIDRaw"
    }

    // Added to tell Realm the main index for the data
    override class func indexedProperties() -> [String] {
        return ["noteTimestampRaw"]
    }
    
    // The initializer for Realm
    convenience init(message: String, lockStatus: LockStatus) {
        self.init()

        self.noteUUID = UUID()
        self.message = message
        self.lockStatus = lockStatus
        self.noteTimestamp = NSDate()

    }
    
//    // Default new note initializer
//    convenience required init() {
//        self.init()
//
//        self.noteUUID = UUID()
//        self.message = ""
//        self.lockStatus = .unlocked
//        self.noteTimestamp = NSDate()
//
//        updateRealmData()
//    }
    

//    // New note initializer with message and lock status and timestamp
//    init(message: String, lockStatus: LockStatus, timestamp: NSDate) {
//
//        self.noteUUID = NEW_UUID!
//        self.message = message
//        self.lockStatus = lockStatus
//        self.noteTimestamp = timestamp
//        //self.noteData = nil
//    }

//    init(noteData: NoteData) {
//
//        self.noteUUID = noteData.noteUUID!
//        self.message = noteData.noteMessage!
//        self.lockStatus =  LockStatus(rawValue: noteData.noteLockState!)!
//        //self.noteData = noteData
//    }
    
//    func loadNoteData(noteData: NoteData) {
//
//        noteData.noteUUID = self.noteUUID
//        noteData.noteMessage = self.message
//        noteData.noteLockState = self.lockStatus.rawValue
//    }
    
    func setLockStatus(isLocked: Bool) {

        REALM_QUEUE.sync {
            do {
                // Create the Realm instance
                let realm = try Realm()
                // Perform the write to Realm
                try realm.write {
                    if isLocked {
                        lockStatus = .locked
                    } else {
                        lockStatus = .unlocked
                    }
                    self.noteTimestamp = NSDate()
                    try realm.commitWrite()
                }
            } catch {
                debugPrint("ERROR writing the Locked Status to Realm!")
            }
        }


    }
    
    func setMessage(message: String) {

        // Add the Realm update
        REALM_QUEUE.sync {
            do {
                // Create the Realm instance
                let realm = try Realm()
                // Perform the write to Realm
                try realm.write {
                    self.message = message
                    self.noteTimestamp = NSDate()
                    try realm.commitWrite()
                }
            } catch {
                debugPrint("ERROR writing the Message to Realm!")
            }
        }

    }

    func isNoteLocked() -> Bool {
        if self.lockStatus == .locked {
            return true
        } else {
            return false
        }
    }
    
    func flipLockStatus() {

        // Add the Realm update
        REALM_QUEUE.sync {
            do {
                // Create the Realm instance
                let realm = try Realm()
                // Perform the write to Realm
                try realm.write {
                    if self.lockStatus == .locked {
                        self.lockStatus = .unlocked
                    } else {
                        self.lockStatus = .locked
                    }
                    self.noteTimestamp = NSDate()

                    try realm.commitWrite()
                }
            } catch {
                debugPrint("ERROR adding note to Realm!")
            }
        }
    }
    
    
    // Function to save the Note to persisten storage
    func saveToData(completion: (_ finished: Bool) -> ()) {
        
        // Update the realm data items before saving to ensure they are current
        if noteUUID == NEW_UUID {
            noteUUID = UUID()
        }
        
        REALM_QUEUE.sync {
            do {
                // Create the Realm instance
                let realm = try Realm()
                // Perform the write to Realm
                try realm.write {
                    realm.add(self)
                    // Not really required but makes sure the write is commited and done
                    try realm.commitWrite()
                }
                
            } catch {
                debugPrint("ERROR adding note to Realm!")
            }
        }
        
//
//        //let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        // Using this version as it does not require me to Import UIKit into my class
//        guard let appDelegate : AppDelegate = AppDelegate().sharedInstance() else { return }
//
//        // Getting the Managed Context to work with the CoreData tools
//        guard let managedContext = appDelegate.persistentContainer.viewContext as NSManagedObjectContext? else { return }
//        // Creating the new goal data object as Goal data type from the managed context
//
//        if noteUUID == NEW_UUID {
//            // This is a new note so we just create it
//
//            // Create a new NoteData object to work with
//            let newNoteData = NoteData(context: managedContext)
//
//            // Setting the properties of the Goal data obejct
//            newNoteData.noteUUID = UUID()
//            newNoteData.noteMessage = self.message
//            newNoteData.noteLockState = self.lockStatus.rawValue
//
//            // Save the data to storage
//            do {
//                try managedContext.save()
//                print("Successfuly saved data!!")
//                completion(true)
//            } catch {
//                debugPrint("Could not save \(error.localizedDescription)")
//                completion(false)
//            }
//
//        } else {
//            // Saving an existig item by retreiving it from storage and then saving it
//
//            let fetchRequest = NSFetchRequest<NoteData>(entityName: "NoteData")
//            // create an NSPredicate to get the instance you want to make change
//            let predicate = NSPredicate(format: "noteUUID = %@", self.noteUUID.uuidString)
//            fetchRequest.predicate = predicate
//
//            // Using a Do/Try/Catch to make the final save call of the managed context to write the data to storage
//            // Also setting the value of the completion handler based on our success in saving the data.
//            do {
//                // Loading the goals array with the data retreived from storage
//                let noteDataArray = try managedContext.fetch(fetchRequest) as [NoteData]
//
//                // Setting the properties of the Goal data obejct
//                if noteDataArray.count == 1 {
//                    print("Successfully fetched 1 note of data for updating.")
//                    noteDataArray[0].noteMessage = self.message
//                    noteDataArray[0].noteLockState = self.lockStatus.rawValue
//
//                    try managedContext.save()
//
//                    completion(true)
//                } else if noteDataArray.count == 0 {
//                    debugPrint("Could not fetch note data with UUID: \(self.noteUUID.uuidString)")
//                    completion(false)
//
//                } else {
//                    debugPrint("Returned more than one note data with UUID: \(self.noteUUID.uuidString)")
//                    completion(false)
//                }
//
//            } catch {
//                debugPrint("Could not fetch note data: \(error.localizedDescription)")
//                completion(false)
//            }
//
//        }
        
    }

    
    // Retreives the data from persisten storage and loads them to the local goals array
    static func getNotesFromData(completion: (_ complete: Bool) -> ()) -> Results<Note>? {
        
        do {
            let realm = try Realm()
            var realmNotes = realm.objects(Note.self)
            realmNotes = realmNotes.sorted(byKeyPath: "noteTimestamp", ascending: false)
            completion(true)

            return realmNotes

        } catch {
            debugPrint("No data returned")
            completion(false)

            return nil

        }

        
//        // Using this version as it does not require me to Import UIKit into my class
//        guard let appDelegate : AppDelegate = AppDelegate().sharedInstance() else { return [Note]() }
//
//        // Get the managed context for this app
//        guard let managedContext = appDelegate.persistentContainer.viewContext as? NSManagedObjectContext else  { return [Note]() }
//
//        // Define the request we are making as a type Goal using the entity name "Goal" from the data model
//        let fetchRequest = NSFetchRequest<NoteData>(entityName: "NoteData")
//        var notes = [Note]()
//
//        do {
//            // Loading the goals array with the data retreived from storage
//            let noteDataArray = try managedContext.fetch(fetchRequest)
//            print("Successfully fetched note data.")
//
//            var newNote: Note
//            for dataItem in noteDataArray {
//                newNote = Note(noteData: dataItem)
//                notes.append(newNote)
//            }
//
//            completion(true)
//
//        } catch {
//            debugPrint("Could not fetch note data: \(error.localizedDescription)")
//            completion(false)
//        }
//
//        return notes
    }

    // Used to remove a specific goal from our data based on the indexPath being passed in
    func deleteFromData(completion: (_ complete: Bool) -> ()) {
       
        REALM_QUEUE.sync {
            do {
                // Create the Realm instance
                let realm = try Realm()
                // Perform the write to Realm
                try realm.write {
                    realm.delete(self)
                    // Not really required but makes sure the write is commited and done
                    try realm.commitWrite()
                }
            } catch {
                debugPrint("ERROR adding note to Realm!")
            }
        }
        
//        // Using this version as it does not require me to Import UIKit into my class
//        guard let appDelegate : AppDelegate = AppDelegate().sharedInstance() else { return }
//
//        // Get the managed context for this app
//        guard let managedContext = appDelegate.persistentContainer.viewContext as? NSManagedObjectContext else { return }
//
//        let fetchRequest = NSFetchRequest<NoteData>(entityName: "NoteData")
//        // create an NSPredicate to get the instance you want to make change
//        let predicate = NSPredicate(format: "noteUUID = %@", self.noteUUID.uuidString)
//        fetchRequest.predicate = predicate
//
//        do {
//            // Loading the goals array with the data retreived from storage
//            let noteDataArray = try managedContext.fetch(fetchRequest)
//
//            if noteDataArray.count == 1 {
//                print("Successfully fetched note data.")
//
//                // Delete the item from our managed context
//                managedContext.delete(noteDataArray[0])
//
//                completion(true)
//            } else if noteDataArray.count == 0 {
//                debugPrint("Could not fetch note data: \(self.noteUUID.uuidString)")
//                completion(false)
//
//            } else {
//                debugPrint("Returned more than one note data: \(self.noteUUID.uuidString)")
//                completion(false)
//            }
//
//        } catch {
//            debugPrint("Could not fetch note data: \(error.localizedDescription)")
//            completion(false)
//        }
//
//        // Perform a Do/Try/Catch to save the context which will remove the deleted item from storage
//        do {
//            try managedContext.save()
//            print("Successfully deleted a goal!")
//        } catch {
//            debugPrint("Could not delete a goal: \(error.localizedDescription)")
//        }
    }

}
