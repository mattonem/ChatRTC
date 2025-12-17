Class {
	#name : 'SignalingMessage',
	#superclass : 'Announcement',
	#instVars : [
		'message'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingMessage >> message [

	^ message
]

{ #category : 'accessing' }
SignalingMessage >> message: anObject [

	message := anObject
]
