Class {
	#name : 'SignalingNewContact',
	#superclass : 'Announcement',
	#instVars : [
		'contact'
	],
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC-Core'
}

{ #category : 'accessing' }
SignalingNewContact >> contact [

	^ contact
]

{ #category : 'accessing' }
SignalingNewContact >> contact: anObject [

	contact := anObject
]
