Class {
	#name : 'SignalingOfferReceived',
	#superclass : 'Announcement',
	#instVars : [
		'offer'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingOfferReceived >> offer [

	^ offer
]

{ #category : 'accessing' }
SignalingOfferReceived >> offer: anObject [

	offer := anObject
]
