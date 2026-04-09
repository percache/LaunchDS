//
//  CreditsView.swift
//  LaunchdDS
//
//  Credits screen with contributor avatars loaded from GitHub.
//

import SwiftUI

struct CreditsView: View {
    @State var people: [CreditsPerson] = []

    var body: some View {
        List {
            Section(header: Text("Contributors")) {
                ForEach(people, id: \.self) { person in
                    CreditsPersonView(person: person)
                        .onTapGesture {
                            UIApplication.shared.open(person.socialLink)
                        }
                }
            }

            Section(header: Text("About")) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("LaunchdDS")
                        .font(.system(size: 17, weight: .bold))
                    Text("System Log Viewer + Kernel Exploit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Based on Antoine by Serena")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            people = CreditsPerson.allContributors
        }
        .navigationBarTitle("Credits")
    }
}

struct CreditsPersonView: View {
    var person: CreditsPerson
    @State var img = Image(systemName: "person.circle")
    var body: some View {
        HStack {
            img
                .resizable()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(person.name)
                    .font(.system(size: 16, weight: .semibold))
                Text(person.role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            URLSession.shared.dataTask(with: person.pfpURL) { data, _, _ in
                if let data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.img = Image(uiImage: uiImage)
                    }
                }
            }
            .resume()
        }
    }
}
