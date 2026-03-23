# SmithLife (스미스라이프)

> 피트니스 센터 통합 관리 모바일 앱

<br>

## 📱 화면 소개

### 인증
| 스플래시 | 로그인 | 회원가입 |
|:---:|:---:|:---:|
| <img src="img/splash.png" width="180"/> | <img src="img/login.png" width="180"/> | <img src="img/signup.png" width="180"/> |

### 홈 & 출석
| 홈 | QR 출석 |
|:---:|:---:|
| <img src="img/Home.png" width="180"/> | <img src="img/entrance.png" width="180"/> |

### 예약
| 예약 목록 | 날짜 선택 | 시간 선택 | 예약 확인 |
|:---:|:---:|:---:|:---:|
| <img src="img/reserve.png" width="180"/> | <img src="img/reserve1.png" width="180"/> | <img src="img/reserve2.png" width="180"/> | <img src="img/reserve3.png" width="180"/> |

### 운동 기록
| 루틴 선택 | 운동 시작 | 세트 기록 | 타이머 | 완료 | 요약 |
|:---:|:---:|:---:|:---:|:---:|:---:|
| <img src="img/workout.png" width="120"/> | <img src="img/workout1.png" width="120"/> | <img src="img/workout2.png" width="120"/> | <img src="img/workout3.png" width="120"/> | <img src="img/workout4.png" width="120"/> | <img src="img/workout5.png" width="120"/> |

### 공지사항
| 공지 목록 | 공지 상세 |
|:---:|:---:|
| <img src="img/공지사항.png" width="180"/> | <img src="img/공지사항1.png" width="180"/> |

### 관리자
| 관리자 홈 | 회원 관리 | 회원 등록 |
|:---:|:---:|:---:|
| <img src="img/admin.png" width="180"/> | <img src="img/admin_customer.png" width="180"/> | <img src="img/customer_register.png" width="180"/> |

<br>

## 🛠 기술 스택

| 계층 | 기술 |
|------|------|
| **Frontend** | Flutter (Dart) + Riverpod + MVVM |
| **Backend** | Spring Boot + Spring Security + JWT |
| **Database** | MySQL 8.0 |
| **Infra** | AWS EC2, RDS, S3 |
| **기타** | Redis (토큰 관리), FCM (푸시 알림) |

<br>

## 📂 프로젝트 구조

```
SmithLife/
├── backend/          # Spring Boot API 서버
├── frontend/         # Flutter 모바일 앱
├── docs/             # 산출물 (API 명세서, ERD, 요구사항명세서)
├── img/              # 스크린샷
├── .gitignore
└── README.md
```

<br>

## ✨ 주요 기능

- **회원 인증** : 회원가입, 로그인, JWT 토큰 관리
- **QR 출석** : QR 코드 스캔 기반 출석 체크인/체크아웃
- **시설 예약** : 시간대별 시설 예약 및 관리
- **운동 기록** : 세션 기반 운동 기록 (세트, 무게, 횟수, 타이머)
- **루틴 관리** : 나만의 운동 루틴 생성 및 추천 루틴 제공
- **리포트** : 주간/월간 운동 통계 및 개인 기록
- **알림** : FCM 기반 푸시 알림 (예약, 출석, 공지)
- **커뮤니티** : 공지사항, FAQ, 1:1 문의
- **관리자** : 회원 관리, 멤버십 등록, 공지사항 작성

<br>

## 📋 산출물

- [요구사항명세서 v3.0](docs/SmithLife_요구사항명세서_v3.0.pdf)
- [API 명세서 v2.0](docs/SmithLife_API명세서_v2.0.xlsx)
- [ERD](ERD.png)
- [DDL](smithlife_ddl.sql)

<br>

## 🌿 브랜치 전략

| 브랜치 | 용도 |
|--------|------|
| `main` | 배포 가능한 안정 버전 |
| `develop` | 개발 통합 브랜치 |
| `feat/*` | 기능 개발 |
| `fix/*` | 버그 수정 |
| `hotfix/*` | 긴급 수정 |

<br>

## 📝 커밋 컨벤션

```
<type>(<scope>): <subject>
```

| Type | 용도 |
|------|------|
| `init` | 초기 설정 |
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 |
| `style` | 코드 포맷팅 |
| `refactor` | 리팩토링 |
| `test` | 테스트 |
| `chore` | 빌드/설정 변경 |
