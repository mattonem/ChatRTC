Class {
	#name : 'SignalingMessage',
	#superclass : 'Announcement',
	#instVars : [
		'message'
	],
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC-Core'
}

{ #category : 'accessing' }
SignalingMessage >> message [

	^ message
]

{ #category : 'accessing' }
SignalingMessage >> message: anObject [

	message := anObject
]
