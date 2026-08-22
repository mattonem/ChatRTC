Class {
	#name : 'SignalingLocalMessage',
	#superclass : 'Announcement',
	#instVars : [
		'message'
	],
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC-Core'
}

{ #category : 'accessing' }
SignalingLocalMessage >> message [

	^ message
]

{ #category : 'accessing' }
SignalingLocalMessage >> message: anObject [

	message := anObject
]
