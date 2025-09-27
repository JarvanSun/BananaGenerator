import Foundation

/// Template section for grouping templates
struct TemplateSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String  // SF Symbol
    let templates: [Template]

    /// All template sections
    static var allSections: [TemplateSection] {
        [
            TemplateSection(
                title: "Toys & Collectibles",
                icon: "cube.fill",
                templates: Template.toysTemplates
            ),
            TemplateSection(
                title: "Art & Illustration",
                icon: "paintbrush.fill",
                templates: Template.artTemplates
            ),
            TemplateSection(
                title: "Photo Enhancement",
                icon: "wand.and.stars",
                templates: Template.enhancementTemplates
            ),
            TemplateSection(
                title: "Fashion & Style",
                icon: "sparkles",
                templates: Template.fashionTemplates
            ),
            TemplateSection(
                title: "Creative Effects",
                icon: "theatermasks.fill",
                templates: Template.creativeTemplates
            ),
            TemplateSection(
                title: "Product & Design",
                icon: "cube.transparent.fill",
                templates: Template.productTemplates
            ),
            TemplateSection(
                title: "Portraits",
                icon: "person.crop.rectangle.fill",
                templates: Template.portraitTemplates
            )
        ]
    }

    /// Get all templates flattened from all sections
    static var allTemplatesFlatMapped: [Template] {
        allSections.flatMap { $0.templates }
    }
}