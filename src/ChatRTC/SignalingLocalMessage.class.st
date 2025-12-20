Class {
	#name : 'SignalingLocalMessage',
	#superclass : 'Announcement',
	#instVars : [
		'message'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingLocalMessage >> message [

	^ message
]

{ #category : 'accessing' }
SignalingLocalMessage >> message: anObject [

	message := anObject
]
