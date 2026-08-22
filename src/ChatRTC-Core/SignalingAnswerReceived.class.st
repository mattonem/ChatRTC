Class {
	#name : 'SignalingAnswerReceived',
	#superclass : 'Announcement',
	#instVars : [
		'answer'
	],
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC-Core'
}

{ #category : 'accessing' }
SignalingAnswerReceived >> answer [

	^ answer
]

{ #category : 'accessing' }
SignalingAnswerReceived >> answer: anObject [

	answer := anObject
]
