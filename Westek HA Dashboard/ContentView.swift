import SwiftUI
import Combine
import CocoaMQTT

let mqttBroker = "172.16.100.11"
let mqttPort: UInt16 = 1883

class MQTTManager: NSObject, ObservableObject, CocoaMQTTDelegate {
    var mqtt: CocoaMQTT!
    @Published var lampState: Bool = false
    @Published var partyState: Bool = false

    override init() {
        super.init()
        let clientID = "WesTekDashboard-\(Int.random(in: 1000...9999))"
        mqtt = CocoaMQTT(clientID: clientID, host: mqttBroker, port: mqttPort)
        mqtt.delegate = self
        _ = mqtt.connect()
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        mqtt.subscribe("stat/sonoff/office/lamp/POWER")
        mqtt.subscribe("stat/sonoff/office/partylights/POWER")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let payload = message.string ?? ""
        DispatchQueue.main.async {
            if message.topic == "stat/sonoff/office/lamp/POWER" {
                self.lampState = payload == "ON"
            }
            if message.topic == "stat/sonoff/office/partylights/POWER" {
                self.partyState = payload == "ON"
            }
        }
    }

    func toggle(topic: String, state: Bool) {
        mqtt.publish(topic, withString: state ? "ON" : "OFF")
    }

    // Required delegate stubs
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
}

struct ContentView: View {
    @StateObject var mqttManager = MQTTManager()

    var body: some View {
        VStack(spacing: 16) {
            Text("WesTek Office")
                .font(.headline)
                .padding(.top)

            Divider()

            HStack {
                Text("Lamp")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { mqttManager.lampState },
                    set: { newValue in
                        mqttManager.lampState = newValue
                        mqttManager.toggle(topic: "cmnd/sonoff/office/lamp/POWER", state: newValue)
                    }
                ))
                .labelsHidden()
            }
            .padding(.horizontal)

            HStack {
                Text("Party Lights")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { mqttManager.partyState },
                    set: { newValue in
                        mqttManager.partyState = newValue
                        mqttManager.toggle(topic: "cmnd/sonoff/office/partylights/POWER", state: newValue)
                    }
                ))
                .labelsHidden()
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(width: 300, height: 200)
    }
}
