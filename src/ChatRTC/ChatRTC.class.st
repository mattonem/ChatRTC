Class {
	#name : 'ChatRTC',
	#superclass : 'PjFileBasedWebApp',
	#traits : 'StaticComponentHolder',
	#classTraits : 'StaticComponentHolder classTrait',
	#pools : [
		'RTCGlobals',
		'WebWorkerGlobals'
	],
	#classInstVars : [
		'staticComponents'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
ChatRTC class >> appClasses [

	<pharoJsSkip>
	^ super appClasses , { ChatRTCWidget . PubNubSignalingClient  }
]

{ #category : 'accessing' }
ChatRTC class >> bridgeClass [
	<pharoJsSkip>
	^ PjBridge
]

{ #category : 'accessing' }
ChatRTC class >> bridgeClientClass [
	<pharoJsSkip>
	
	^ PjZnHostedBrowserBridgeClient
]

{ #category : 'accessing' }
ChatRTC class >> exporterClass [

	<pharoJsSkip>
	^ PjFileExporterWithIndexHtml
]

{ #category : 'accessing' }
ChatRTC class >> generateHtmlUsing: html [

	<pharoJsSkip>
	html div
		class: 'container mt-5';
		with: [
			html div
				class: 'row justify-content-center';
				with: [
					self
						addComponent: (ChatRTCWidget  new)
						named: #main
						on: html ] ]
]

{ #category : 'accessing' }
ChatRTC class >> initialize [ 
	<pharoJsSkip>
	super initialize.
]

{ #category : 'accessing' }
ChatRTC class >> staticComponentsSerialized [

	<jsLiteralGenerator>
	^ self _staticComponents asPhxJsonString
]

{ #category : 'accessing' }
ChatRTC class >> updateHtmlRoot: root [

	<pharoJsSkip>
	root language: 'en'.
	root stylesheet url:
		'https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css'.
	root stylesheet url:
		'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css'.
	root script url:
		'https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.js'.
		
]

{ #category : 'accessing' }
ChatRTC class >> workers [

	^ { WebWorker }
]

{ #category : 'initialize-release' }
ChatRTC >> start [

	| worker |
	self initializeComponentHolder.
	super start.
	worker := WebWorker createWorker: WebWorker.

	worker postMessage: (SignalingAnswerReceived new
			 answer: 'hi';
			 yourself).
	worker announcer
		when: SignalingAnswerReceived
		do: [ :aMessage | console log: aMessage ]
		for: self
]
