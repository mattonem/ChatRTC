Class {
	#name : 'SignalingNewContact',
	#superclass : 'Announcement',
	#instVars : [
		'contact'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingNewContact >> contact [

	^ contact
]

{ #category : 'accessing' }
SignalingNewContact >> contact: anObject [

	contact := anObject
]
