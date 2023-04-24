//
//  GlobalConst.swift
//  Radio
//
//  Created by Oleksandr Haidaiev on 24.04.2023.
//

enum GlobalConst {}

#if DEBUG
extension GlobalConst {
    enum Fake {
        static let apiDelay = 0.5
    }
}
#endif

