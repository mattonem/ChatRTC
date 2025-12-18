Class {
	#name : 'SignalingAnswerReceived',
	#superclass : 'Announcement',
	#instVars : [
		'answer'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingAnswerReceived >> answer [

	^ answer
]

{ #category : 'accessing' }
SignalingAnswerReceived >> answer: anObject [

	answer := anObject
]
