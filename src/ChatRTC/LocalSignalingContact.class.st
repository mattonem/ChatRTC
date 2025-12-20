Class {
	#name : 'LocalSignalingContact',
	#superclass : 'SignalingContact',
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
LocalSignalingContact >> postMessage: anObject [

	LocalSignalingClient announcer announce:
		(SignalingLocalMessage new message: {
				 (#d -> anObject).
				 (#i -> originAddress).
				 (#target -> address) } asJsObject)
]
