class DesignerModel {
  final int id;
  final int userId;
  final String studioName;
  final String fullName;
  final String specialty;
  final String? bio;
  final String? education;
  final String? awards;
  final int experienceYears;
  final int projectsCompleted;
  final String? averageProjectDuration;
  final bool isOpen;
  final String image;
  final String? banner;
  final String? instagramUrl;
  final String? linkedinUrl;
  final double rating;
  final List<PortfolioModel>? portfolios;
  final Map<String, dynamic>? freeConsultation;

  DesignerModel({
    required this.id,
    required this.userId,
    required this.studioName,
    required this.fullName,
    required this.specialty,
    this.bio,
    this.education,
    this.awards,
    required this.experienceYears,
    required this.projectsCompleted,
    this.averageProjectDuration,
    required this.isOpen,
    required this.image,
    this.banner,
    this.instagramUrl,
    this.linkedinUrl,
    required this.rating,
    this.portfolios,
    this.freeConsultation,
  });

  factory DesignerModel.fromJson(Map<String, dynamic> json) {
    return DesignerModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      studioName: json['studio_name'],
      fullName: json['full_name'],
      specialty: json['specialty'] ?? '',
      bio: json['bio'],
      education: json['education'],
      awards: json['awards'],
      experienceYears: json['experience_years'] ?? 0,
      projectsCompleted: json['projects_completed'] ?? 0,
      averageProjectDuration: json['average_project_duration'] ?? '-',
      isOpen: json['is_open'] == 1 || json['is_open'] == true,
      image: json['image'],
      banner: json['banner'],
      instagramUrl: json['instagram_url'],
      linkedinUrl: json['linkedin_url'],
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      portfolios: json['portfolios'] != null 
          ? (json['portfolios'] as List).map((p) => PortfolioModel.fromJson(p)).toList() 
          : null,
      freeConsultation: json['free_consultation'],
    );
  }
}

class PortfolioModel {
  final int id;
  final String? title;
  final String imageUrl;
  final String? description;
  final String? category;
  final String? budget;
  final String? area;
  final String? duration;
  final bool is360;
  final Map<String, dynamic>? review;

  PortfolioModel({
    required this.id, 
    this.title,
    required this.imageUrl, 
    this.description,
    this.category,
    this.budget,
    this.area,
    this.duration,
    this.is360 = false,
    this.review,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'] ?? '',
      description: json['description'],
      category: json['category'],
      budget: json['budget'],
      area: json['area'],
      duration: json['duration'],
      is360: json['is_360'] == 1 || json['is_360'] == true || json['is_360'] == '1',
      review: json['review'],
    );
  }
}
