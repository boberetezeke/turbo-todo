import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  connect() {
    this.draggedItem = null
    this.dropTarget = null
    this.dropPosition = null
  }

  dragStart(event) {
    this.draggedItem = event.currentTarget
    this.draggedItem.classList.add("dragging")

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedItem.dataset.todoId)
  }

  dragEnd() {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("dragging")
    }

    this.clearDropMarkers()
    this.draggedItem = null
    this.dropTarget = null
    this.dropPosition = null
  }

  dragOver(event) {
    if (!this.draggedItem) {
      return
    }

    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const target = this.findDropTarget(event.clientY)
    if (!target) {
      this.clearDropMarkers()
      this.dropTarget = null
      this.dropPosition = null
      return
    }

    this.clearDropMarkers()
    target.item.classList.add(target.position === "before" ? "drop-before" : "drop-after")

    this.dropTarget = target.item
    this.dropPosition = target.position
  }

  async drop(event) {
    if (!this.draggedItem) {
      return
    }

    event.preventDefault()

    if (!this.dropTarget) {
      const fallbackTarget = this.findDropTarget(event.clientY)
      if (fallbackTarget) {
        this.dropTarget = fallbackTarget.item
        this.dropPosition = fallbackTarget.position
      }
    }

    if (!this.dropTarget) {
      return
    }

    const belowItem = this.dropPosition === "before" ? this.dropTarget : this.nextTodoItem(this.dropTarget)
    const targetOrder = belowItem ? Number.parseInt(belowItem.dataset.todoOrder, 10) : this.maxOrder() + 1

    if (!Number.isInteger(targetOrder) || targetOrder < 1) {
      return
    }

    const response = await fetch(this.draggedItem.dataset.updateUrl, {
      method: "PATCH",
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ todo: { order: targetOrder } })
    })

    if (response.ok) {
      Turbo.renderStreamMessage(await response.text())
    }
  }

  findDropTarget(clientY) {
    const todoItems = this.todoItems()

    if (todoItems.length === 0) {
      return null
    }

    const firstItem = todoItems[0]
    const firstRect = firstItem.getBoundingClientRect()
    if (clientY < firstRect.top + firstRect.height / 2) {
      return { item: firstItem, position: "before" }
    }

    for (const item of todoItems) {
      const rect = item.getBoundingClientRect()
      if (clientY <= rect.bottom) {
        const isBefore = clientY < rect.top + rect.height / 2
        return { item, position: isBefore ? "before" : "after" }
      }
    }

    return { item: todoItems[todoItems.length - 1], position: "after" }
  }

  todoItems() {
    return Array.from(this.element.querySelectorAll("[data-todo-id]"))
      .filter((item) => item !== this.draggedItem)
  }

  nextTodoItem(todoItem) {
    let next = todoItem.nextElementSibling

    while (next && !next.dataset.todoId) {
      next = next.nextElementSibling
    }

    return next
  }

  maxOrder() {
    return Array.from(this.element.querySelectorAll("[data-todo-order]"))
      .map((item) => Number.parseInt(item.dataset.todoOrder, 10))
      .filter((value) => Number.isInteger(value))
      .reduce((max, value) => Math.max(max, value), 0)
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }

  clearDropMarkers() {
    this.element.querySelectorAll(".drop-before, .drop-after").forEach((item) => {
      item.classList.remove("drop-before", "drop-after")
    })
  }
}

