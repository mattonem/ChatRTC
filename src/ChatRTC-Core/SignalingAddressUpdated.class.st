Class {
	#name : 'SignalingAddressUpdated',
	#superclass : 'Announcement',
	#instVars : [
		'address'
	],
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC-Core'
}

{ #category : 'accessing' }
SignalingAddressUpdated >> address [

	^ address
]

{ #category : 'accessing' }
SignalingAddressUpdated >> address: anObject [

	address := anObject
]
