//
//  ViewController.swift
//  TableViewPaging
//
//  Created by Robin Malhotra on 19/03/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

extension UIScrollView {
	var distanceToBottom: CGFloat {
		return abs(self.contentOffset.y + self.frame.height - self.contentSize.height - self.safeAreaInsets.bottom - self.contentInset.bottom)
	}

	var distanceFromTop: CGFloat {
		return abs(self.contentOffset.y + self.safeAreaInsets.top + self.contentInset.top)
	}
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {

	let tableView = UITableView()

	var numbers = Array(0...50)

	var currentlyBatchFetching = false

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(tableView)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)

		tableView.scrollToRow(at: IndexPath(row: numbers.count/2, section: 0), at: .middle, animated: false)

		tableView.prefetchDataSource = self
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = view.bounds
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//does messing with this value cause changes in memory issues
		return numbers.count
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let pageSize = 20
		if scrollView.distanceToBottom < 100 && currentlyBatchFetching == false {
			//TODO: weakify self
			currentlyBatchFetching = true
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
				let lastNumber = self.numbers.last!
				let moarNumbers = Array((lastNumber+1)...lastNumber + pageSize)
				self.numbers += moarNumbers
//				self.numbers.removeFirst(pageSize/2)
				self.tableView.reloadData()
				self.currentlyBatchFetching = false
			}
		}
		print(scrollView.distanceFromTop)
		if scrollView.distanceFromTop < 100 && currentlyBatchFetching == false {
			//TODO: weakify self
			currentlyBatchFetching = true
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
				let firstNumber = self.numbers.first!
				let moarNumbers = Array((firstNumber - pageSize)..<firstNumber)
				let oldContentHeight: CGFloat = self.tableView.contentSize.height
				let oldOffsetY: CGFloat = self.tableView.contentOffset.y
				self.numbers = moarNumbers + self.numbers
				self.numbers.removeLast(pageSize/2)
				self.tableView.reloadData()
				let newContentHeight: CGFloat = self.tableView.contentSize.height
				let newContentOffsetY = oldOffsetY + (newContentHeight - oldContentHeight)
				self.tableView.contentOffset.y = newContentOffsetY
				self.currentlyBatchFetching = false
			}
		}
	}


	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = "\(numbers[indexPath.row])"
		return cell
	}


	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		print(indexPaths)
	}

	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		print(indexPaths)
	}

}
