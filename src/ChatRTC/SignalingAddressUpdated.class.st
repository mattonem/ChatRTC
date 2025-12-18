Class {
	#name : 'SignalingAddressUpdated',
	#superclass : 'Announcement',
	#instVars : [
		'address'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingAddressUpdated >> address [

	^ address
]

{ #category : 'accessing' }
SignalingAddressUpdated >> address: anObject [

	address := anObject
]
