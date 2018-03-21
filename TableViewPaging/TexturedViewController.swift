//
//  TexturedViewController.swift
//  TableViewPaging
//
//  Created by Robin Malhotra on 20/03/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

class TexturedViewController: UIViewController, ASTableDataSource, ASTableDelegate, ASBatchFetchingDelegate {

	let tableNode = ASTableNode()

	var numbers = Array(1..<100)

    override func viewDidLoad() {
        super.viewDidLoad()

		tableNode.dataSource = self
		tableNode.leadingScreensForBatching = 3.0
		self.view.addSubnode(tableNode)
		tableNode.batchFetchingDelegate = self
		tableNode.delegate = self

        // Do any additional setup after loading the view.
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		tableNode.onDidFinishProcessingUpdates { [weak self] in
			self?.tableNode.scrollToRow(at: IndexPath(row: (self?.numbers.count ?? 0)/2, section: 0), at: .middle, animated: false)
		}

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableNode.frame = view.bounds
	}

	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}

	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return numbers.count
	}

	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let node = ASTextCellNode.init()
		node.text = "\(numbers[indexPath.row])"
		return node
	}

	func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
		return hint

	}

	func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
		print("batching")
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in

			guard let strongSelf = self else {
				return
			}

			let pageSize = 20

			if tableNode.contentOffset.y < tableNode.frame.height {
				let min = strongSelf.numbers.first!
				let moarNumbers = Array((min-pageSize)..<min)
				strongSelf.numbers = moarNumbers + strongSelf.numbers

				let oldContentHeight = strongSelf.tableNode.view.contentSize.height
				let oldOffsetY = strongSelf.tableNode.contentOffset.y

				strongSelf.tableNode.reloadSections(IndexSet(integer: 0), with: .none)

				strongSelf.tableNode.waitUntilAllUpdatesAreProcessed()
				let newContentHeight = tableNode.view.contentSize.height
				tableNode.contentOffset.y = oldOffsetY + (newContentHeight - oldContentHeight)

				strongSelf.numbers.removeLast(pageSize)

			} else {
				let max = strongSelf.numbers.last!
				let moarNumbers = Array(max...max+pageSize)
				let existingNumbers = strongSelf.numbers.count
				strongSelf.numbers += moarNumbers
				let indexPaths = (existingNumbers..<(existingNumbers + moarNumbers.count)).map { IndexPath.init(row: $0, section: 0) }
				strongSelf.numbers.removeFirst(pageSize)
				strongSelf.tableNode.reloadSections(IndexSet(integer: 0), with: .none)

			}
			context.completeBatchFetching(true)

		}
	}

}
