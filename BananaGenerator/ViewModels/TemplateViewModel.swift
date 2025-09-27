import Foundation
import SwiftUI

@Observable
class TemplateViewModel {
    private(set) var templates = Template.allTemplates
    private(set) var selectedTemplate: Template?
    
    func selectTemplate(_ template: Template) {
        selectedTemplate = template
    }
    
    func clearSelection() {
        selectedTemplate = nil
    }
}