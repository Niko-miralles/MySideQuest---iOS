import SwiftUI

struct OnboardingView: View {
    @Environment(GameStore.self) private var store
    @State private var mode: Mode = .welcome
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    enum Mode { case welcome, signup, login }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.white, SQ.lav], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                PixelAvatar(seed: "sidequest-logo", size: 110)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(SQ.gold)
                            .offset(x: 10, y: -10)
                    }

                Text("SIDE")
                    .font(.px(30)) + Text("QUEST")
                    .font(.px(30)).foregroundStyle(SQ.violet)
                Text("Tu ciudad es ahora un juego")
                    .font(.fredoka(18, weight: .medium))
                    .foregroundStyle(SQ.muted)
                    .padding(.top, 10)

                if mode != .welcome { form }
                Spacer()

                VStack(spacing: 12) {
                    switch mode {
                    case .welcome:
                        Button("Crear cuenta") { withAnimation { mode = .signup } }
                            .buttonStyle(PixelButtonStyle())
                        Button("Ya tengo cuenta") { withAnimation { mode = .login } }
                            .buttonStyle(PixelButtonStyle(bg: .white, fg: SQ.violet,
                                                          pressedBg: SQ.lav))
                    case .signup:
                        Button("Crear cuenta") { submit(signup: true) }
                            .buttonStyle(PixelButtonStyle())
                        backButton
                    case .login:
                        Button("Entrar") { submit(signup: false) }
                            .buttonStyle(PixelButtonStyle())
                        backButton
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
    }

    private var form: some View {
        VStack(spacing: 12) {
            if mode == .signup { field("Nombre de aventurero", text: $name) }
            field("Email", text: $email, keyboard: .emailAddress)
            SecureField("Contraseña", text: $password)
                .textFieldStyle(.plain)
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(SQ.line))
            if let error {
                Text(error).font(.fredoka(14)).foregroundStyle(SQ.pink)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 28)
    }

    private func field(_ placeholder: String, text: Binding<String>,
                       keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.plain)
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(SQ.line))
    }

    private var backButton: some View {
        Button("Volver") { withAnimation { mode = .welcome; error = nil } }
            .font(.fredoka(15, weight: .semibold))
            .foregroundStyle(SQ.muted)
    }

    private func submit(signup: Bool) {
        do {
            if signup { try store.signUp(name: name, email: email, password: password) }
            else { try store.logIn(email: email, password: password) }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
