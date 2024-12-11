//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Defaults
import JellyfinAPI
import SwiftUI

struct ServerUserPermissionsView: View {

    // MARK: - Observed & Environment Objects

    @EnvironmentObject
    private var router: BasicNavigationViewCoordinator.Router

    @ObservedObject
    var viewModel: ServerUserAdminViewModel

    // MARK: - Policy Variable

    @State
    private var tempPolicy: UserPolicy

    // MARK: - Error State

    @State
    private var error: Error?

    // MARK: - Initializer

    init(viewModel: ServerUserAdminViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.tempPolicy = viewModel.user.policy ?? UserPolicy()
    }

    // MARK: - Body

    var body: some View {
        contentView
            .navigationTitle(L10n.permissions)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarCloseButton {
                router.dismissCoordinator()
            }
            .topBarTrailing {
                if viewModel.backgroundStates.contains(.updating) {
                    ProgressView()
                }
                Button(L10n.save) {
                    if tempPolicy != viewModel.user.policy {
                        viewModel.send(.updatePolicy(tempPolicy))
                    }
                }
                .buttonStyle(.toolbarPill)
                .disabled(viewModel.user.policy == tempPolicy)
            }
            .onReceive(viewModel.events) { event in
                switch event {
                case let .error(eventError):
                    UIDevice.feedback(.error)
                    error = eventError
                case .updated:
                    UIDevice.feedback(.success)
                    router.dismissCoordinator()
                }
            }
            .errorMessage($error)
    }

    // MARK: - Content View

    @ViewBuilder
    var contentView: some View {
        switch viewModel.state {
        case let .error(error):
            ErrorView(error: error)
        case .initial:
            ErrorView(error: JellyfinAPIError(L10n.loadingUserFailed))
        default:
            permissionsListView
        }
    }

    // MARK: - Permissions List View

    @ViewBuilder
    var permissionsListView: some View {
        List {
            StatusSection(policy: $tempPolicy)

            ManagementSection(policy: $tempPolicy)

            MediaPlaybackSection(policy: $tempPolicy)

            ExternalAccessSection(policy: $tempPolicy)

            SyncPlaySection(policy: $tempPolicy)

            RemoteControlSection(policy: $tempPolicy)

            PermissionSection(policy: $tempPolicy)

            SessionsSection(policy: $tempPolicy)
        }
    }
}