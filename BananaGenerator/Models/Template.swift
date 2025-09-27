import Foundation
import SwiftUI

struct Template: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let coverImageName: String  // Cover image from Assets (required)
    let prompt: String
    
    enum CodingKeys: String, CodingKey {
        case name, coverImageName, prompt
    }
    
    // MARK: - Toys & Collectibles Templates
    static let toysTemplates: [Template] = [
        Template(
            name: "3D Model",
            coverImageName: "3d-template",
            prompt: AppConfig.Prompts.figurinePrompt
        ),
        Template(
            name: "Funko Pop",
            coverImageName: "funko-pop-placeholder",
            prompt: "Transform the person into a Funko Pop figure, shown inside and next to its packaging."
        ),
        Template(
            name: "LEGO Minifigure",
            coverImageName: "lego-placeholder",
            prompt: "Transform the person into a LEGO minifigure, inside its packaging box."
        ),
        Template(
            name: "Crochet Doll",
            coverImageName: "crochet-placeholder",
            prompt: "Transform the subject into a handmade crocheted yarn doll with a cute, chibi-style appearance."
        ),
        Template(
            name: "Plushie",
            coverImageName: "plushie-placeholder",
            prompt: "Turn the person in this photo into a cute, soft plushie doll."
        ),
        Template(
            name: "Acrylic Keychain",
            coverImageName: "keychain-placeholder",
            prompt: "Turn the subject into a cute acrylic keychain, shown attached to a bag."
        )
    ]

    // MARK: - Art & Illustration Templates
    static let artTemplates: [Template] = [
        Template(
            name: "Line Art",
            coverImageName: "line-art-placeholder",
            prompt: "Turn the image into a clean, hand-drawn line art sketch."
        ),
        Template(
            name: "Art Process",
            coverImageName: "painting-process-placeholder",
            prompt: "Generate a 4-panel grid showing the artistic process of creating this image, from sketch to final render."
        ),
        Template(
            name: "Marker Sketch",
            coverImageName: "marker-sketch-placeholder",
            prompt: "Redraw the image in the style of a Copic marker sketch, often used in design."
        ),
        Template(
            name: "Van Gogh Style",
            coverImageName: "van-gogh-placeholder",
            prompt: "Reimagine the photo in the style of Van Gogh's 'Starry Night'."
        )
    ]

    // MARK: - Photo Enhancement Templates
    static let enhancementTemplates: [Template] = [
        Template(
            name: "HD Enhancement",
            coverImageName: "hd-enhance-placeholder",
            prompt: "Enhance this image to high resolution, improving sharpness and clarity."
        ),
        Template(
            name: "Photorealistic",
            coverImageName: "photorealistic-placeholder",
            prompt: "Turn this illustration into a photorealistic version."
        ),
        Template(
            name: "Isolate & Enhance",
            coverImageName: "isolate-enhance-placeholder",
            prompt: "Isolate the person in the masked area and generate a high-definition photo of them against a neutral background."
        )
    ]

    // MARK: - Fashion & Style Templates
    static let fashionTemplates: [Template] = [
        Template(
            name: "Fashion Magazine",
            coverImageName: "fashion-magazine-placeholder",
            prompt: "Transform the photo into a stylized, ultra-realistic fashion magazine portrait with cinematic lighting."
        ),
        Template(
            name: "Hyper-Realistic",
            coverImageName: "hyper-realistic-placeholder",
            prompt: "Generate a hyper-realistic, fashion-style photo with strong, direct flash lighting, grainy texture, and a cool, confident pose."
        ),
        Template(
            name: "Anime Cosplay",
            coverImageName: "cosplay-placeholder",
            prompt: "Generate a highly detailed, realistic photo of a person cosplaying the character in this illustration. Replicate the pose, expression, and framing."
        )
    ]

    // MARK: - Creative Effects Templates
    static let creativeTemplates: [Template] = [
        Template(
            name: "Cyberpunk",
            coverImageName: "cyberpunk-placeholder",
            prompt: "Transform the scene into a futuristic cyberpunk city."
        ),
        Template(
            name: "Y2K Background",
            coverImageName: "y2k-background-placeholder",
            prompt: "Change the background to a Y2K aesthetic style."
        ),
        Template(
            name: "3D Screen Effect",
            coverImageName: "3d-screen-placeholder",
            prompt: "For an image with a screen, add content that appears to be glasses-free 3D, popping out of the screen."
        ),
        Template(
            name: "Add Illustration",
            coverImageName: "add-illustration-placeholder",
            prompt: "Add a cute, cartoon-style illustrated couple into the real-world scene, sitting and talking."
        ),
        Template(
            name: "Makeup Analysis",
            coverImageName: "makeup-analysis-placeholder",
            prompt: "Analyze the makeup in this photo and suggest improvements by drawing with a red pen."
        )
    ]

    // MARK: - Product & Design Templates
    static let productTemplates: [Template] = [
        Template(
            name: "Architecture Model",
            coverImageName: "architecture-placeholder",
            prompt: "Convert this photo of a building into a miniature architecture model, placed on a cardstock in an indoor setting. Show a computer with modeling software in the background."
        ),
        Template(
            name: "Product Render",
            coverImageName: "product-render-placeholder",
            prompt: "Turn this product sketch into a photorealistic 3D render with studio lighting."
        ),
        Template(
            name: "Soda Can Design",
            coverImageName: "soda-can-placeholder",
            prompt: "Design a soda can using this image as the main graphic, and show it in a professional product shot."
        ),
        Template(
            name: "Industrial Design",
            coverImageName: "industrial-design-placeholder",
            prompt: "Turn this industrial design sketch into a realistic product photo, rendered with light brown leather and displayed in a minimalist museum setting."
        )
    ]

    // MARK: - Legacy all templates (kept for backward compatibility)
    static let allTemplates: [Template] = {
        // Flatten all template arrays to maintain backward compatibility
        toysTemplates + artTemplates + enhancementTemplates +
        fashionTemplates + creativeTemplates + productTemplates
    }()

    // MARK: - Portrait templates for professional and artistic portraits
    static let portraitTemplates: [Template] = [
        Template(
            name: "Professional Portrait",
            coverImageName: "professional-portrait-placeholder",
            prompt: """
            将上传的人像转换为美式风格的专业 headshot（企业高管摄影风格），需保留原照片人物的面部特征和身份。
            要求：半身像，蓝色纹理背景，自然柔和的棚拍打光，高清清晰，肤色真实自然，画面简洁优雅。
            人物穿无袖黑色连衣裙，简约优雅设计，直筒略收身版型，面料光滑无图案，现代感与专业感兼具，搭配简约金色首饰，整体现代干练。【男生的话这部分让AI帮忙改下即可】
            表情放松自信，眼神有神，自然露齿微笑。
            镜头对焦清晰，背景轻微虚化，整体效果专业、精致、干净。
            生成2张不同角度、姿势的照片。
            """
        ),
        Template(
            name: "B&W Art Portrait",
            coverImageName: "bw-art-placeholder",
            prompt: """
            将上传的照片生成黑白肖像艺术作品，采用编辑类和艺术摄影风格。
            背景呈现柔和渐变效果，从中灰过渡到近乎纯白，营造出层次感与寂静氛围。细腻的胶片颗粒质感为画面培添了一种可触摸的、模拟摄影般的柔和质地，让人联想到经典的黑白摄影。
            他的脸部因为光线的轮廓，唤起神秘、亲密与优雅之感。他的五官精致而深刻，散发出忧郁与诗意之美，却不显矫饰。
            一束温柔的定向光，柔和地漫射开来，轻抚他的面颊曲线，或在眼中闪现光点—这是画面的情感核心。其余部分以大量负空间占据，刻意保持简洁，使画面自由呼吸。画面中没有文字、没有标志——只有光影与情绪交织。
            生成4张照片不同姿势
            """
        )
    ]
}
