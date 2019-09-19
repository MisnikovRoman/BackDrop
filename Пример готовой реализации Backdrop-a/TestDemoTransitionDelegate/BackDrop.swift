//
//  BackDrop.swift
//  TestDemoTransitionDelegate
//
//  Created by MisnikovRoman on 25.08.2019.
//  Copyright © 2019 MisnikovRoman. All rights reserved.
//

import UIKit

final class BackDropTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BackDropPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

final class BackDropPresentationController: UIPresentationController {
    enum State {
        case full, dismiss
    }

    /// Константы с размерами
    private enum Metrics {
        /// Минимальный масштаб presenting view, когда bottom sheet полностью развернут
        static let backDropMinScale: CGFloat = 0.9
        /// Радиус скругления углов presenting view, когда bottom sheet полностью развернут
        static let backDropCornerRadius: CGFloat = 16
        /// Высота прозрачной вью
        static let topClearViewHeight: CGFloat = 32
        /// Размеры индикатора back drop-a
        static let backDropIndicatorSize = CGSize(width: 32, height: 4)
        /// Коэффициент прозрачности снапшота
        static let snapshotAlpha: CGFloat = 0.7
        /// Отступ сверху до края presented view
        static let topInset: CGFloat = 14
        /// Расстояние раскрытого состояния backDrop-a до позиции начала анимации при перетягивании
        static let startAnimationDistance: CGFloat = 100
        /// Предельное значение скорости перемещения модального окна для срабатывания привязки
        /// к одному из состояний BottomSheetState
        static let velocityLimit: CGFloat = 200
        /// Длительность анимации
        static let animationDuration = 0.3
        /// Минимальная высота  статус бара на старых девайсах (<= 8)
        static let maxOldPhoneStatusHeight: CGFloat = 25
        /// Отступ сверху для старых девайсов (<= 8)
        static let oldPhoneTopInset: CGFloat = 30
        /// Позиция скрытия боттом шита относительно высоты экрана
        static let absCloseBottomShitPosition: CGFloat = 0.7
        /// Коэффициент сопротивления скорости перемещения модального окна (0...1 )
        /// где при 0 - модальное окно не двигается, при 1 - следует за пальцем
        static let bottomSheetSpeedResistance: CGFloat = 1 // 0.5
        /// Основной фрейм для устройства
        static let screenBounds: CGRect = UIScreen.main.bounds
    }

    /// Расстояние от верхнего края до конца челки (статус бара)
    private var topSpace: CGFloat {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        return (statusBarHeight < Metrics.maxOldPhoneStatusHeight)
            ? Metrics.oldPhoneTopInset
            : statusBarHeight
    }

    /// Положение модального окна
    private var state: State = .full
    /// Масштаб снапшота PresentingViewController
    private var snapshotWidthConstraint: NSLayoutConstraint!
    /// Snapshot PresentingViewController
    private var snapshotView: UIView?
    private var blackView: UIView?
    private var transparentView: UIView?
    /// Жест Pan для перемещения модального окна
    private var panGesture: UIGestureRecognizer?

    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(
            x: 0,
            y: topSpace + Metrics.topInset,
            width: Metrics.screenBounds.width,
            height: Metrics.screenBounds.height
        )
    }

    override func presentationTransitionWillBegin() {
        self.preparePresentingView()
        self.presentedView?.layer.cornerRadius = Metrics.backDropCornerRadius

        UIView.animate(withDuration: Metrics.animationDuration) {
            self.snapshotWidthConstraint.constant = Metrics.screenBounds.width * Metrics.backDropMinScale
            self.snapshotView?.layoutIfNeeded()
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        presentedViewController.view.addGestureRecognizer(pan)
        self.panGesture = pan
    }

    override func dismissalTransitionWillBegin() {
        self.blackView?.removeFromSuperview()
        self.snapshotView?.removeFromSuperview()
        self.transparentView?.removeFromSuperview()
    }
}

extension BackDropPresentationController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension BackDropPresentationController {
    func createBlackView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func createSnapshot() -> UIView {
        let snapshotView = presentingViewController.view.snapshotView(afterScreenUpdates: false)!
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        snapshotView.layer.masksToBounds = true
        snapshotView.layer.cornerRadius = Metrics.backDropCornerRadius
        return snapshotView
    }

    func createTransparentView() -> UIView {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3990528682)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func preparePresentingView() {
        guard let presentingView = self.presentingViewController.view else { return }
        presentingView.layer.cornerRadius = Metrics.backDropCornerRadius
        presentingView.layer.masksToBounds = true

        let blackView = createBlackView()
        let snapshot = createSnapshot()
        let transparentView = createTransparentView()

        self.blackView = blackView
        self.snapshotView = snapshot
        self.transparentView = transparentView

        presentingView.addSubview(blackView)
        presentingView.addSubview(snapshot)
        presentingView.addSubview(transparentView)

        self.snapshotWidthConstraint = snapshot.widthAnchor.constraint(equalToConstant: Metrics.screenBounds.width)

        NSLayoutConstraint.activate([
            blackView.topAnchor.constraint(equalTo: presentingView.topAnchor),
            blackView.bottomAnchor.constraint(equalTo: presentingView.bottomAnchor),
            blackView.leadingAnchor.constraint(equalTo: presentingView.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: presentingView.trailingAnchor),

            snapshotWidthConstraint,
            snapshot.centerXAnchor.constraint(equalTo: presentingView.centerXAnchor),
            snapshot.centerYAnchor.constraint(equalTo: presentingView.centerYAnchor),
            snapshot.heightAnchor.constraint(equalTo: snapshot.widthAnchor,
                                             multiplier: Metrics.screenBounds.height / Metrics.screenBounds.width),

            transparentView.topAnchor.constraint(equalTo: presentingView.topAnchor),
            transparentView.bottomAnchor.constraint(equalTo: presentingView.bottomAnchor),
            transparentView.leadingAnchor.constraint(equalTo: presentingView.leadingAnchor),
            transparentView.trailingAnchor.constraint(equalTo: presentingView.trailingAnchor),
        ])
    }

    func remap(_ number: CGFloat, from oldRange: ClosedRange<CGFloat>, to newRange: ClosedRange<CGFloat>) -> CGFloat {
        let newDistance = newRange.upperBound-newRange.lowerBound
        let oldDistance = oldRange.upperBound - oldRange.lowerBound
        return (((number - oldRange.lowerBound) * newDistance) / oldDistance) + newRange.lowerBound
    }

    func nearestState(for point: CGPoint) -> State {
        let minimum: CGFloat = 0
        let maximum = self.presentingViewController.view.frame.height
        let closeBottomShitPosition = (minimum + maximum) * Metrics.absCloseBottomShitPosition

        switch self.presentingViewController.view.frame.height - point.y {
        case minimum..<closeBottomShitPosition:
            return .dismiss
        case closeBottomShitPosition..<maximum:
            return .full
        default:
            assertionFailure("Модальный экран вышел за пределы допустимой высоты")
            return .dismiss
        }
    }

    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let bottomSheetView = self.presentedView else { return }

        switch recognizer.state {
        case .changed:
            // перемещение модального окна за пальцем
            let translation = recognizer.translation(in: bottomSheetView)
            var newY = bottomSheetView.frame.origin.y + translation.y * Metrics.bottomSheetSpeedResistance
            guard abs(translation.x) < abs(translation.y) else { return }

            // ограничение перемещения view
            newY = min(newY, Metrics.screenBounds.height) // нижняя граница
            newY = max(newY, self.topSpace + Metrics.topInset) // верхняя граница

            // перемещение модального окна
            bottomSheetView.center = CGPoint(x: bottomSheetView.center.x, y: bottomSheetView.frame.height / 2 + newY)

            // если расстояние до верхней позиции меньше startAnimationDistance - меняем масштаб снапшота
            let scale = min(1.0, remap(newY - (Metrics.topInset + topSpace),
                                       from: 0...Metrics.startAnimationDistance,
                                       to: Metrics.backDropMinScale...1.0))
            self.snapshotWidthConstraint.constant = Metrics.screenBounds.width * scale
            self.snapshotView?.setNeedsLayout()

            // обязательный сброс значения реконгнайзера
            recognizer.setTranslation(.zero, in: bottomSheetView)
        case .ended:
            // скрытие / возвращение модального окна
            let yVelocity = recognizer.velocity(in: self.presentingViewController.view).y

            self.state = self.nearestState(for: bottomSheetView.frame.origin)

            if yVelocity > Metrics.velocityLimit{
                self.state = .dismiss
            }
            else if yVelocity < Metrics.velocityLimit * -1 {
                self.state = .full
            }

            guard self.state != .dismiss else {
                presentedViewController.dismiss(animated: true)
                return
            }

            UIView.animate(withDuration: Metrics.animationDuration) {
                bottomSheetView.frame = self.frameOfPresentedViewInContainerView
            }
        default:
            break
        }
    }
}
