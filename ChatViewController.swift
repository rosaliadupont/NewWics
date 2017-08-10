//
//  ChatViewController.swift
//  WICS
//
//  Created by Rosalia Dupont on 8/1/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {

    
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    
    var messages = [Message]()

    
    // MARK: - VC Lifecycle
    
    var chat: Chat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupJSQMessagesViewController()
        tryObservingMessages()
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)

    }
    
    func setupJSQMessagesViewController() {
        // 1. identify current user
        senderId = User.current.uid
        senderDisplayName = User.current.username
        title = chat.title
        
        // 2. remove attachment button
        //inputToolbar.contentView.leftBarButtonItem = nil
        
        // 3. remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)
    }()
    
    var incomingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
    }()
    
    func tryObservingMessages() {
        guard let chatKey = chat?.key else { return }
        
        messagesHandle = ChatService.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            
            if let message = message {
                self?.messages.append(message)
                self?.finishReceivingMessage()
            }
        })
    }

}


// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController {
    // 1
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // 2
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // 3
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
    
    // 4
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let sender = message.sender
        
        if sender.uid == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // 5
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
        return cell
    }
}

extension ChatViewController {
    func sendMessage(_ message: Message) {
        // 1
        if chat?.key == nil {
            // 2
            ChatService.create(from: message, with: chat, completion: { [weak self] chat in
                guard let chat = chat else { return }
                
                self?.chat = chat
                
                // 3
                self?.tryObservingMessages()
            
            })
        } else {
            // 4
            ChatService.sendMessage(message, for: chat)
        }
        
        
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let message = Message(content: text)
        // 2
        sendMessage(message)
        // 3
        finishSendingMessage()
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        
        if message.content.range(of: "eventbrite.com/e") != nil {
            
            let input = message.content
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            var url = ""
            
            for match in matches {
                url = (input as NSString).substring(with: match.range)
            }
            
            let url1 = URL(string: url)!
            
            let components = URLComponents(url: url1, resolvingAgainstBaseURL: false)!
            let splitArr = components.path.components(separatedBy: CharacterSet(charactersIn: "-") )
            let last = splitArr.last
            print(last ?? "NOTHING")
            
            if last != "NOTHING" {
                ApiClient.apiCall(last!) { (post) in

                print(post?.title ?? "NOTHING RECOGNIZED")
                    
                    PostService.create(title: (post?.title)!, eventDate: (post?.eventDate)!, address: post?.location["address"] as! String, city: post?.location["city"] as! String, latitude: post?.location["latitude"] as! Double, longitude: post?.location["longitude"] as! Double, description: (post?.description)!, completion: { (succeeded) in
                        
                        if succeeded! {
                            print("chat post in database's timeline")
                            
                        }
                        else {
                            print("chat post NOT in database's timeline")
                            
                        }
                    })
                }
            }
            
            
            else { return }
            
            
            
        }
        else if message.content.range(of: "facebook.com/events/") != nil {
            var str = message.content
            
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
            var url = ""
            
            for match in matches {
                url = (str as NSString).substring(with: match.range)
            }
            
            let url1 = URL(string: url)!
            
            let components = URLComponents(url: url1, resolvingAgainstBaseURL: false)!
            
            print(components.path)
            
            var truncated = ""
            
            if components.path.characters.last == "/" {
                truncated = components.path.substring(to: components.path.index(before: components.path.endIndex))
                print(truncated)
            } else {
                truncated = components.path
            }
            
            let splitArr = truncated.components(separatedBy: CharacterSet(charactersIn: "/") )
            let last = splitArr.last
            print(last ?? "NOTHING")
            
            if last != "NOTHING" {
                GraphAPIVC.readEvent(path: last!) { (post) in
                    
                    if post != nil {
                        
                        PostService.create(title: (post?.title)!, eventDate: (post?.eventDate)!, address: post?.location["address"] as! String, city: post?.location["city"] as! String, latitude: post?.location["latitude"] as! Double, longitude: post?.location["longitude"] as! Double, description: (post?.description)!, completion: { (succeeded) in
                            
                            if succeeded! {
                                print("chat post in database's timeline")
                                
                            }
                            else {
                                print("chat post NOT in database's timeline")
                                
                            }
                        })
                    }
                    else {
                        print("ERROR IN READING EVENT!!")
                    }
                    
                }
            }
            
        }

    }
   
    // MARK: JSQMessagesViewController method overrides
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            /**
             *  Create fake photo
             */
            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "wics_back_1"))
            self.addMedia(photoItem!)
        }
        
        let locationAction = UIAlertAction(title: "Send location", style: .default) { (action) in
            /**
             *  Add fake location
             */
            let locationItem = self.buildLocationItem()
            
            self.addMedia(locationItem)
        }
        
        let videoAction = UIAlertAction(title: "Send video", style: .default) { (action) in
            /**
             *  Add fake video
             */
            let videoItem = self.buildVideoItem()
            
            self.addMedia(videoItem)
        }
        
        let audioAction = UIAlertAction(title: "Send audio", style: .default) { (action) in
            /**
             *  Add fake audio
             */
            let audioItem = self.buildAudioItem()
            
            self.addMedia(audioItem)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = URL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        
        return videoItem!
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let mediamessage = Message(content: "this is a media message to test")
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        mediamessage.jsqMessageValue = message!

        self.messages.append(mediamessage)
        
        //Optional: play sent sound
        
        self.finishSendingMessage(animated: true)
    }
    

}
