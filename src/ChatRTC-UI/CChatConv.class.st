Class {
	#name : 'CChatConv',
	#superclass : 'WCComponent',
	#instVars : [
		'connection',
		'signalingContact'
	],
	#category : 'ChatRTC-UI',
	#package : 'ChatRTC-UI'
}

{ #category : 'rendering' }
CChatConv >> addMessage: message fromUser: user [

	| conv |
	conv := self getElementById: #conv.

	conv value:
		conv value , Character cr asString , user , ': ' , message.
	conv scrollTop: conv scrollHeight
]

{ #category : 'rendering' }
CChatConv >> handleAnswer: answer [

	connection handleAnswer: answer
]

{ #category : 'rendering' }
CChatConv >> handleCandidate: aCandidate [

	connection handleCandidate: aCandidate
]

{ #category : 'rendering' }
CChatConv >> handleOffer: anOffer [

	connection handleOffer: anOffer
]

{ #category : 'rendering' }
CChatConv >> renderHtmlOn: html [

	html div
		class: 'card';
		with: [
			html div
				class: 'card-header';
				with: 'Conversation'.
			html div
				class: 'card-body';
				with: [
					html div with: [
							html textArea
								class: 'form-control';
								disabled;
								id: 'conv' ].
					html div with: [
						html textInput
							class: 'form-control';
							id: 'message' ].
					html button
						class: 'btn btn-primary';
						id: 'send';
						with: 'Send' ] ]
]

{ #category : 'rendering' }
CChatConv >> sendCandidate: aCandidate [

	self signalSend: aCandidate
]

{ #category : 'rendering' }
CChatConv >> sendMessage [

	| mess |
	mess := (self getElementById: #message) value.
	self addMessage: mess fromUser: 'I say'.
	connection send: mess.
]

{ #category : 'rendering' }
CChatConv >> sendOffer [

	connection startOffer
]

{ #category : 'rendering' }
CChatConv >> signalSend: aMessage [
	signalingContact send: aMessage
]

{ #category : 'accessing' }
CChatConv >> signalingContact: anObject [

	signalingContact := anObject.
	connection := RTCConnection for: signalingContact.
	connection
		onMessage: [ :message | self addMessage: message fromUser: 'they say' ]
]

{ #category : 'rendering' }
CChatConv >> start [

	super start.
	(self getElementById: #send)
		addEventListener: #click
		block: [ self sendMessage ].
	
]
