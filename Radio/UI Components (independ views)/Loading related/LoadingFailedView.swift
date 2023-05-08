//
//  LoadingFailedView.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 22.04.2023.
//

import SwiftUI

struct LoadingFailedView: View {
    let error: DataProviderError & ErrorWithGeneralRESTWebErrorCase
    
    // TODO: find a way how to cast `error` to `.generalRESTError(let general)`
//    private func mapToWebError() -> RESTWebError? {
//        if case .generalRESTError(let general) = error {
//            return general
//        }
//        return nil
//    }
    
    var body: some View {
        VStack {
            Text("Something went wrong - \(error.localizedDescription)")
        }
    }
}
